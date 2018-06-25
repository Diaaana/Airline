@RestResource(urlMapping='/book_flight')
global with sharing class BookFlightHandler  {

    @HttpPost
    global static String create() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> params = new Map<String, Object>();
        Map<String, Object> result = new Map<String, Object>();
        BookedFlight__c bookedFlight = new BookedFlight__c();

        try {
            params = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        } catch(JSONException ex) {
            result.put('message', 'Flight does not booked' + ex.getMessage() + ' ' + ex.getStackTraceString());
            result.put('status', 'failed');
        }

        //get params
        Date dateFrom = Date.valueOf(params.get('date_from').toString());
        Date dateTo = Date.valueOf(params.get('date_to').toString());
        List<Price__c> availablePrices = [
            SELECT Flight__r.Name, Value__c
            FROM Price__c
            WHERE DateFrom__c <= :dateFrom AND DateTo__c >= :dateTo
            LIMIT 100
        ];

        if ( !availablePrices.isEmpty() ) {
            Decimal totalPrice = dateFrom.daysBetween(dateTo)*availablePrices[0].Value__c;
            insert new BookedFlight__c (
                Flight__c = availablePrices[0].Flight__c,
                DateFrom__c = dateFrom,
                DateTo__c = dateTo,
                TotalPrice__c = totalPrice
                );

            result.put('message', 'Flight successfully booked');
            result.put('status', 'booked');
            result.put('price', totalPrice);

        } else {
            result.put('message', 'This flights are busy');
            result.put('status', 'booked');
        }

        return JSON.serialize(result);

    }

}