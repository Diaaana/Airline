trigger BeforeBookedFlightTrigger on BookedFlight__c (before insert) {
	for(BookedFlight__c bookedFlight : trigger.new) {

		Flight__c flight = [SELECT FreeSeat__c FROM Flight__c WHERE ID = :bookedFlight.Flight__c];

		if (flight.FreeSeat__c == 0) {
			ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR, 
                    'Flight is not available. You can not book this flight!'
                )
            );
            return;
		}
	}
}