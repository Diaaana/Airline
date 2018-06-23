@RestResource(urlMapping='/book_flight')
global with sharing class BookFlightHandler  {

    @HttpPost
    global static String create() {
        BookedFlight__c bookedFlight = new BookedFlight__c();
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> params = new Map<String, Object>();
        Map<String, Object> result = new Map<String, Object>();
        List<Price__c> availablePrices = new List<Price__c>();

        try {
            params = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        } catch(JSONException ex) {
            /*response.responseBody = JSON.serialize(result);*/
            result.put('message', 'Flight does not booked' + ex.getMessage() + ' ' + ex.getStackTraceString());
            result.put('status', 'failed');
        }

        //get params
        Date dateFrom = Date.valueOf(params.get('date_from').toString());
        Date dateTo = Date.valueOf(params.get('date_to').toString());
        availablePrices = [
            SELECT Flight__r.Name
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

    public static void method() {
        Map<String, Object> params = new Map<String, Object>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ap4.salesforce.com/services/apexrest/book_flight');
        req.setMethod('POST');
        req.setHeader('Authorization', '00D6F000001c5Oy!AQsAQLzBK_IpTq2kaRFZ49cmCV_Pm0KGDRxEseV3o7TgKRuG08fhBNJUbSwtL58u6svDI');
        req.setHeader('Content-type', 'application/json');

        HTTPResponse res = new Http().send(req);
        
        params = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
    }
}