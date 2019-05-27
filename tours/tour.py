#!/usr/bin/env python2
# -*- coding: utf-8 -*-


import constants
from location import Location


class Tour(object):
    def __init__(self, trips, closed):
        self.trips = trips    # list of Trip instances
        self.closed = closed  # boolean

    def __str__(self):
        tour_log = constants.collapse(self.get_types())
        return tour_log

    def get_trips(self):
        return self.trips

    def get_number_of_trips(self):
        return len(self.trips)

    def append(self, trip):
        self.trips.append(trip)

    def get_itypes(self):
        itypes = []
        for trip in self.get_trips():
            itypes.append(trip.get_itype())
        return itypes

    def get_jtypes(self):
        jtypes = []
        for trip in self.get_trips():
            jtypes.append(trip.get_jtype())
        return jtypes

    def get_mode(self):
        trips = self.get_trips()
        lengths = {
            -1: 0.0,
            1: 0.0,
            2: 0.0,
            3: 0.0,
            4: 0.0,
            5: 0.0,
        }
        for trip in trips:
            i = trip.get_mode()
            lengths[i] = lengths[i] + trip.get_length()
        mode = max(lengths, key=lengths.get)
        return mode

    def get_length(self):
        trips = self.get_trips()
        length = 0.0
        for trip in trips:
            length = length + trip.get_length()
        return length

    def includes_trip(self, trip):
        return trip in self.get_trips()

    def get_itime(self):
        return self.get_trips()[0].get_itime()

    def get_jtime(self):
        return self.get_trips()[-1].get_jtime()

    def get_itime_from(self, location):
        trips = self.get_trips()
        ilocations = []
        for trip in trips:
            ilocations.append(trip.get_ilocation())
        try:
            m = ilocations.index(location)
        except ValueError:
            return ""
        itime = trips[m].get_itime()
        return itime

    def get_ilocation(self):
        return self.get_trips()[0].get_ilocation()

    def get_jlocation(self):
        return self.get_trips()[-1].get_jlocation()

    def get_locations(self):
        # Returns unique visited Locations at the order of visits.
        trips = self.trips
        locations = list()
        for trip in trips:
            locations.append(trip.get_ilocation())
            locations.append(trip.get_jlocation())
        seen = set()
        return [x for x in locations if not (x in seen or seen.add(x))]

    def get_types(self):
        # If Tour is closed, appends the type of the first Location at the end
        # of the list of types.
        locations = self.get_locations()
        if self.is_closed():
            locations.append(locations[0])
        types = list()
        for location in locations:
            types.append(location.get_type())
        return types

    def get_itype(self):
        return self.get_ilocation().get_type()

    def get_jtype(self):
        return self.get_jlocation().get_type()

    def is_closed(self):
        return self.closed

    def starts_from(self, ttype):
        first_type = self.get_itype()
        return first_type == ttype

    def ends_to(self, ttype):
        last_type = self.get_jtype()
        return last_type == ttype

    def get_source(self):
        if self.is_closed():
            ttype = self.get_trips()[0].get_itype()
        else:
            if (self.starts_from(constants.TYPE_HOME) or
                    self.ends_to(constants.TYPE_HOME)):
                ttype = constants.TYPE_HOME
            else:
                ttype = -1
        return ttype

    def get_origin(self):
        locations = self.get_locations()
        priorities = list()
        for location in locations:
            priority = location.get_priority()
            priorities.append(priority)
        m = priorities.index(min(priorities))
        origin = locations[m]
        return origin

    def get_destination(self, origin):
        # Destination is searched from other Locations apart from origin,
        # unless origin is the only Location that is ever visited. If there are
        # multiple Locations with same priority, the farthest one is chosen.
        locations = self.get_locations()
        priorities = list()
        distances = list()
        low_priority = max(constants.TYPE_PRIORITY.values()) + 100
        for location in locations:
            priority = location.get_priority()
            if location is origin:
                # Destination is not origin unless the tour is only
                # origin-origin.
                priorities.append(low_priority)
                distances.append(0.0)
            else:
                priorities.append(priority)
                distance = origin.eucd(location)
                # In case of `nan` coordinates, the distance between Locations
                # is zero. If there are several destination candidates of same
                # priority, choosing a Location with missing coordinates is
                # very unlikely.
                distances.append(constants.if_nan_then(distance, 0.0))
        destination_priority = min(priorities)
        farthest_distance = -1
        m = -1
        for index, location in enumerate(locations, start=0):
            if (priorities[index] == destination_priority and
                    distances[index] >= farthest_distance):
                m = index
                farthest_distance = distances[index]
        destination = locations[m]
        return destination

    def get_secondary_destination(self, origin, destination, empty_location):
        # Secondary destination is searched from other Locations apart from
        # origin and destination. If there are
        # multiple Locations with same priority, the farthest one is chosen.
        # If no other locations apart from origin and destination can not be
        # found, empty_location is returned.
        locations = [location for location in self.get_locations() if
                     location is not origin and location is not destination]
        if not locations:
            return empty_location
        priorities = list()
        distances = list()
        low_priority = max(constants.TYPE_PRIORITY.values()) + 100
        for location in locations:
            priority = location.get_priority()
            priorities.append(priority)
            distance1 = origin.eucd(location)
            distance2 = destination.eucd(location)
            distances.append(constants.if_nan_then(distance1, 0.0) +
                             constants.if_nan_then(distance2, 0.0))
        destination_priority = min(priorities)
        farthest_distance = -1
        m = -1
        for index, location in enumerate(locations, start=0):
            if (priorities[index] == destination_priority and
                    distances[index] >= farthest_distance):
                m = index
                farthest_distance = distances[index]
        destination = locations[m]
        return destination

    def get_number_of_visits(self, ttype):
        # Calculates the number of visits to a certain type of location. If Tour
        # is closed, the return trip will not be calculated as new visit.
        locations = self.get_locations()
        types = []
        for location in locations:
            types.append(location.get_type())
        return types.count(ttype)

    def get_tour_type(self, origin, destination, secondary_destination):
        groups = list()
        groups.append(origin.get_group())
        if (destination is not origin):
            groups.append(destination.get_group())
        if (secondary_destination.get_type() != -1):
            groups.append(secondary_destination.get_group())
        tour_type = constants.collapse(groups)
        return tour_type

    def get_order_of_visits(self, origin, destination, secondary_destination):
        locations = self.get_locations()
        letters = ["A", "B", "C"]
        if origin not in locations:
            raise ValueError("`origin` not in tour!")
        if destination not in locations:
            raise ValueError("`destination` not in tour!")
        if secondary_destination not in locations:
            # Does not matter so much if secondary destination does not appear
            # since it can include an empty location anyway.
            if secondary_destination.get_id() == -1:
                letters.remove("C")
            else:
                raise ValueError("`secondary_destination` not in tour!")
        if origin is destination:
            if secondary_destination.get_id() == -1:
                letters.remove("B")
            else:
                print "`origin` and `destination` are the same but still `secondary_destination` exists!"
        # Finally, find out positions of each location
        indices = list()
        if "A" in letters:
            indices.append(locations.index(origin))
        if "B" in letters:
            indices.append(locations.index(destination))
        if "C" in letters:
            indices.append(locations.index(secondary_destination))
        # https://stackoverflow.com/a/6618543
        location_order = [letter for _, letter in sorted(zip(indices, letters))]
        return "".join(location_order)

    def to_dict(self):
        empty_location = Location(tid=-1, ttype=-1, tx=-1, ty=-1, zone=-1)
        origin = self.get_origin()
        destination = self.get_destination(origin)
        secondary_destination = self.get_secondary_destination(origin,
                                                               destination,
                                                               empty_location)
        res = {
                "no_of_trips": self.get_number_of_trips(),
                "closed": self.is_closed(),
                "itime": self.get_itime(),
                "jtime": self.get_jtime(),
                "path": self.__str__(),
                "source": self.get_source(),
                "origin": origin.get_type(),
                "destination": destination.get_type(),
                "secondary_destination": secondary_destination.get_type(),
                "itime_origin": self.get_itime_from(origin),
                "itime_destination": self.get_itime_from(destination),
                "itime_secondary_destination": self.get_itime_from(secondary_destination),
                "zone_origin": origin.get_zone(),
                "zone_destination": destination.get_zone(),
                "zone_secondary_destination": secondary_destination.get_zone(),
                "order": self.get_order_of_visits(origin,
                                                  destination,
                                                  secondary_destination),
                "tour_type": self.get_tour_type(origin,
                                                destination,
                                                secondary_destination),
                "visits_t1": self.get_number_of_visits(1),
                "visits_t2": self.get_number_of_visits(2),
                "visits_t3": self.get_number_of_visits(3),
                "visits_t4": self.get_number_of_visits(4),
                "visits_t5": self.get_number_of_visits(5),
                "visits_t6": self.get_number_of_visits(6),
                "visits_t7": self.get_number_of_visits(7),
                "visits_t8": self.get_number_of_visits(8),
                "visits_t9": self.get_number_of_visits(9),
                "visits_t10": self.get_number_of_visits(10),
                "visits_t11": self.get_number_of_visits(11),
                "visits_t12": self.get_number_of_visits(12),
                "starts_from": self.get_itype(),
                "ends_to": self.get_jtype(),
                "mode": self.get_mode(),
                "length": self.get_length(),
                }
        return res
