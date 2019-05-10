#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import pandas
import json
import constants
from person import Person
from trip import Trip
from tour import Tour
from location import Location
from operator import methodcaller


def sort_list_by_method(list_of_objects, method):
    return sorted(list_of_objects, key=methodcaller(method))


def tours_include_trip(tours, trip):
    trip_in_tours = False
    for tour in tours:
        if tour.includes_trip(trip):
            trip_in_tours = True
            break
    return trip_in_tours


print("python: {}".format(sys.argv[0]))

input_config_filepath = ""
if len(sys.argv) == 1:
    input_config_filepath = "input-config.json"
else:
    input_config_filepath = sys.argv[1]

print("Input data read from: {}".format(input_config_filepath))
with open(input_config_filepath) as f:
    input_config = json.load(f)
print(json.dumps(input_config, indent=4, sort_keys=True))

RESULT_FILE_NAME = input_config["tour-filepath"]
taus = constants.read_people(input_config["people-filepath"],
                             input_config["survey"])
matk = constants.read_trips(input_config["trips-filepath"],
                            input_config["survey"])
paik = constants.read_locations(input_config["locations-filepath"],
                                input_config["survey"])


# Transforming start and end locations to Location objects
locations = list()
for index, row in paik.iterrows():
    new_location = Location(
        row["tid"],
        row["ttype"],
        row["x"],
        row["y"],
        row["zone"]
        )
    locations.append(new_location)
# Sorting locations by their id. Ids go from 1 to n.
locations = sort_list_by_method(locations, "get_id")


# Transforming taustatiedot into Person objects
people = list()
for index, row in taus.iterrows():
    # Creating a new Person object
    new_person = Person(row["pid"], row["xfactor"], row["rzone"])
    # Subsetting his/her trips from all trips
    matk_subset = matk.loc[matk["pid"] == new_person.get_id()]
    # Creating a list of objects of class Trip
    new_diary = []
    for index, row in matk_subset.iterrows():
        # Searching for start and end location objects by id. Locations are
        # already organized by their id from 1 to n.
        ilocation = locations[row["itid"]-1]
        jlocation = locations[row["jtid"]-1]
        # If no results were found, raise an expection
        if ilocation is None:
            raise TypeError("Start location not found!")
        elif jlocation is None:
            raise TypeError("End location not found!")
        elif (ilocation.get_id() != row["itid"]):
            raise ValueError("Start ids are not matching!")
        elif (jlocation.get_id() != row["jtid"]):
            raise ValueError("End ids are not matching!")
        else:
            pass
        new_trip = Trip(
            eid=row["eid"],
            number=row["number"],
            itime=row["itime"],
            jtime=row["jtime"],
            mode=row["mode"],
            length=row["length"],
            ilocation=ilocation,
            jlocation=jlocation
            )
        new_diary.append(new_trip)
    # Add newly created trip list to the Person object
    new_person.set_diary(new_diary)
    # Save new person to people list
    people.append(new_person)


# Loop people
for person in people:
    if not person.makes_trips():
        continue

    diary = person.get_diary()

    full_tours = []
    # Go through all trips from first to last. Find the first return trip to
    # the starting location. If return trip exists, create a tour.
    for trip in diary:
        index_of_departure = diary.index(trip)
        remaining_trips = diary[index_of_departure:]

        # Get the index of return trip
        index_of_return = -1
        for remaining_trip in remaining_trips:
            if (remaining_trip is not trip and
                    remaining_trip.get_ilocation() is trip.get_ilocation()):
                # Person has never arrived to the starting location but is now
                # starting from it. This implies missing trips in diary. Tour
                # is open-ended, so it is skipped. It will be handled later as
                # well as other open tours.
                break
            if remaining_trip.get_jlocation() is trip.get_ilocation():
                # Person arrives to the same location: closed tour is saved.
                index_of_return = diary.index(remaining_trip)
                break

        # If return trip was found, save a tour
        if index_of_return > -1:
            new_full_tour = Tour(
                diary[index_of_departure:(index_of_return+1)],
                True
                )
            full_tours.append(new_full_tour)

    tours = []
    # Remove subtours from large tours by saving tours from the last to first
    # so that tours starting early do not include trips that belong into
    # tours beginning later.
    full_tours.reverse()
    for full_tour in full_tours:
        new_tour = full_tour
        for later_tour in tours:
            # One trip can not belong to several tours so we will select trips
            # that belong into this tour but not any later tour
            unique_trips = [trip for trip in new_tour.get_trips() if trip not in later_tour.get_trips()]
            new_tour = Tour(unique_trips, True)
        # Consider a diary where the person goes from home to gym and back two
        # times. These form originally three tours: home-gym-home,
        # gym-home-gym, and home-gym-home. After searching for unique trips,
        # we must make sure that the tour is still closed.
        if new_tour.get_ilocation() is new_tour.get_jlocation():
            tours.append(new_tour)
    tours.reverse()

    # Are there trips that do not belong to any tour? These trips are most
    # likely open-ended tours.
    trips_not_in_tours = []
    for trip in diary:
        if not tours_include_trip(tours, trip):
            trips_not_in_tours.append(trip)

    open_ended_tours = []
    for trip in trips_not_in_tours:
        # If trip was already added to open-ended tours, continue
        if tours_include_trip(open_ended_tours, trip):
            continue

        # Define open-ended tour: an open-ended tour is always discontinued,
        # if a person visits home, or if trips are skipped.
        index_starting = trips_not_in_tours.index(trip)
        index_ending = len(trips_not_in_tours) - 1
        remaining_trips = trips_not_in_tours[index_starting:]
        last_number = trip.get_number()
        for remaining_trip in remaining_trips:
            index_ending = trips_not_in_tours.index(remaining_trip)
            if (remaining_trip is not trip):
                # If remaining trips skip a number, the tour is then finished
                # because this means that there is a closed tour in between.
                if (remaining_trip.get_number() != (last_number + 1)):
                    index_ending = index_ending - 1
                    break
                # If the current remaining trip suddenly starts from home, tour
                # is finished. Usually this means that there are missing trips
                # in person's travel diary.
                if (remaining_trip.get_itype() == constants.TYPE_HOME):
                    index_ending = index_ending - 1
                    break
            # A tour is finished if person arrives home.
            if remaining_trip.get_jtype() == constants.TYPE_HOME:
                break
            last_number = remaining_trip.get_number()

        open_ended_tour = Tour(
            trips_not_in_tours[index_starting:(index_ending+1)],
            False
            )
        open_ended_tours.append(open_ended_tour)

    tours.extend(open_ended_tours)

    tours = sort_list_by_method(tours, "get_itime")
    person.set_tours(tours)

# Print result to console
# for person in people:
#     print "Person {}".format(person.get_id())
#     for num, tour in enumerate(person.get_tours(), start=1):
#         print "  {}. {}".format(num, tour)

# Get a list of all tours
tour_dictionaries = []
for person in people:
    for tour in person.get_tours():
        new_dictionary = person.to_dict()
        new_dictionary.update(tour.to_dict())
        tour_dictionaries.append(new_dictionary)

# Write tours to CSV
tour_output = pandas.DataFrame.from_records(tour_dictionaries)
tour_output["pid"] = tour_output["pid"].astype(int)

tour_output.to_csv(RESULT_FILE_NAME,
                   index=False,
                   sep=";",
                   decimal=",",
                   columns=["pid",
                            "xfactor",
                            "rzone",
                            "tour_type",
                            "no_of_trips",
                            "closed",
                            "source",
                            "starts_from",
                            "ends_to",
                            "itime",
                            "jtime",
                            "origin",
                            "destination",
                            "itime_origin",
                            "itime_destination",
                            "zone_origin",
                            "zone_destination",
                            "mode",
                            "length",
                            "path",
                            "visits_t1",
                            "visits_t2",
                            "visits_t3",
                            "visits_t4",
                            "visits_t5",
                            "visits_t6",
                            "visits_t7",
                            "visits_t8",
                            "visits_t9",
                            "visits_t10",
                            "visits_t11",
                            "visits_t12",
                            ])
print "Finished!"


# Are there the same amount of trips in diaries and in tours?
errors = 0
for person in people:
    number_of_diary_trips = len(person.get_diary())
    number_of_tour_trips = 0
    tours = person.get_tours()
    for tour in tours:
        number_of_tour_trips = number_of_tour_trips + tour.get_number_of_trips()
    if number_of_diary_trips != number_of_tour_trips:
        errors = errors + 1

print "Number of people with missing trips: {}".format(errors)
