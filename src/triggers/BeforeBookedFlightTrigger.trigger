trigger BeforeBookedFlightTrigger on BookedFlight__c (before insert) {
	for(BookedFlight__c bookedFlight : trigger.new) {

		Flight__c flight = [SELECT isBooked__c FROM Flight__c WHERE ID = :bookedFlight.Flight__c];

		if (flight.isBooked__c == true) {
			System.assert(false, 'Flight is not available. You can not book this flight!'); 
		}
	}
}