trigger AfterBookedFlightTrigger on BookedFlight__c (after insert) {
	for(BookedFlight__c bookedFlight : trigger.new) {

		Flight__c flight = [SELECT isBooked__c FROM Flight__c WHERE ID = :bookedFlight.Flight__c];

		flight.isBooked__c = true;
		
		update flight;
	}
}