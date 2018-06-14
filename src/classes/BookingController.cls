public class BookingController {
    public BookedFlight__c searchFlight { get; set; }
    public List<Price__c> filtrFlight { get; set; }
    public String dataJSON { get; set; }
    public String flightValue;
    public String addonValue;
    public String dateFromValue;
    public String dateToValue;
    
    public BookingController() {
        this.searchFlight = new BookedFlight__c();
        this.flightValue = '';
        this.addonValue = '';
        this.dateFromValue = '';
        this.dateToValue = '';
        this.dataJSON = '';
    }
 
    public void searchFlights() {
        flightValue = ApexPages.currentPage().getParameters().get('flight');
        addonValue = ApexPages.currentPage().getParameters().get('addon');
        dateFromValue = ApexPages.currentPage().getParameters().get('dateFrom');
        dateToValue = ApexPages.currentPage().getParameters().get('dateTo');

        ApexPages.getMessages().clear();
        
        if (Date.valueOf(dateFromValue) > Date.valueOf(dateToValue)) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Date From can not be greater than Date To'
                )
            );
            return;
        }
      
        if (flightValue.equals('') && addonValue.equals('') || dateFromValue.equals('') || dateToValue.equals('')) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return;
        }

        List<String> condition = new List<String>();
        
        String flightName = flightValue;
        String addonName = addonValue;
        Date dateFrom = Date.valueOf(dateFromValue);
        Date dateTo = Date.valueOf(dateToValue);

        if (flightName != null && addonName == null) {
            condition.add('Flight__r.Name = :flightName');
        } else if (flightName == null && addonName != null) {
            condition.add('Addon__r.Name = :addonName');
        } else if (flightName != null && addonName != null) {
            condition.add('Flight__r.Name = :flightName AND Addon__r.Name = :addonName');
        }
        
        String query = 'SELECT Value__c, Flight__c, Addon__c, DateFrom__c, DateTo__c ' + 
            ' FROM Price__c ' + 
            ' WHERE ' + String.join(condition, ' AND ') + 
            ' AND DateFrom__c <= :dateFrom ' +
            ' AND DateTo__c >= :dateTo ' + 
            ' ORDER BY Value__c ASC ' +
            ' LIMIT 1000';
        
        List<Price__c> prices = (List<Price__c>)Database.query(query);
        dataJSON = JSON.serialize(prices);
        /*filtrFlight = prices;*/
    }
    
    public void bookFlight() {
        flightValue = ApexPages.currentPage().getParameters().get('flight');
        addonValue = ApexPages.currentPage().getParameters().get('addon');
        dateFromValue = ApexPages.currentPage().getParameters().get('dateFrom');
        dateToValue = ApexPages.currentPage().getParameters().get('dateTo');
        
        ApexPages.getMessages().clear();
        
        if (Date.valueOf(dateFromValue) > Date.valueOf(dateToValue)) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Date From can not be greater than Date To'
                )
            );
            return;
        }
      
        if (flightValue.equals('') && addonValue.equals('') || dateFromValue.equals('') || dateToValue.equals('')) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return;
        }
        
        List<String> condition = new List<String>();
        
        String flightName = flightValue;
        String addonName = addonValue;
        Date dateFrom = Date.valueOf(dateFromValue);
        Date dateTo = Date.valueOf(dateToValue);

        if (flightName != null && addonName == null) {
            condition.add('Flight__r.Name = :flightName');
        } else if (flightName == null && addonName != null) {
            condition.add('Addon__r.Name = :addonName');
        } else if (flightName != null && addonName != null) {
            condition.add('Flight__r.Name = :flightName AND Addon__r.Name = :addonName');
        }
        
        String query = 'SELECT Value__c, Flight__c, Addon__c, DateFrom__c, DateTo__c ' + 
            ' FROM Price__c ' + 
            ' WHERE ' + String.join(condition, ' AND ') + 
            ' AND DateFrom__c <= :dateFrom ' +
            ' AND DateTo__c >= :dateTo ' + 
            ' ORDER BY Value__c ASC ' +
            ' LIMIT 1000';
        
        List<Price__c> prices = (List<Price__c>)Database.query(query);
        
        Price__c flightPrice = new Price__c();
        Price__c addonPrice = new Price__c();
        
        for (Price__c price : prices) {
            if (price.Flight__c != null) {
                flightPrice = price;
            }
            if (price.Addon__c != null) {
                addonPrice = price;
            }
        }
        
        Decimal flightAmount = 0.0;
        Decimal addonAmount = 0.0;
        Integer allocation = dateFrom.daysBetween(dateTo) + 1;
        if (flightPrice.Id != null) {
            flightAmount = flightPrice.Value__c * allocation;
        } 
        if (addonPrice.Id != null) {
            addonAmount = addonPrice.Value__c * allocation;
        }
        
        insert new BookedFlight__c(
            Flight__c = this.searchFlight.Flight__c,
            Addon__c = this.searchFlight.Addon__c,
            DateFrom__c = this.searchFlight.DateFrom__c,
            DateTo__c = this.searchFlight.DateTo__c,
            TotalPrice__c = flightAmount +  addonAmount
        );
    }
    
}