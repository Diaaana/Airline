public class BookingController {
    public BookedFlight__c searchFlight { get; set; }
    public List<Price__c> filtrFlight { get; set; }
    
    public BookingController() {
        this.searchFlight = new BookedFlight__c();
    }
 
    public void searchFlights() {
        
        ApexPages.getMessages().clear();
        
        if (this.searchFlight.DateFrom__c > this.searchFlight.DateTo__c) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Date From can not be greater than Date To'
                )
            );
            return;
        }
        
        if (this.searchFlight.Flight__c == NULL && this.searchFlight.Addon__c == NULL || this.searchFlight.DateFrom__c == NULL || this.searchFlight.DateTo__c == NULL) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return;
        }
        
        List<String> condition = new List<String>();
        
        Id flightId = this.searchFlight.Flight__c;
        Id addonId = this.searchFlight.Addon__c;
        Date dateFrom = this.searchFlight.DateFrom__c;
        Date dateTo = this.searchFlight.DateTo__c;
        if (flightId != null && addonId == null) {
            condition.add('Flight__c = :flightId');
        } else if (flightId == null && addonId != null) {
            condition.add('Addon__c = :addonId');
        } else if (flightId != null && addonId != null) {
            condition.add('Flight__c = :flightId AND Addon__c = :addonId');
        }
        
        String query = 'SELECT Value__c, Flight__c, Addon__c, DateFrom__c, DateTo__c ' + 
            ' FROM Price__c ' + 
            ' WHERE ' + String.join(condition, ' AND ') + 
            ' AND DateFrom__c <= :dateFrom ' +
            ' AND DateTo__c >= :dateTo ' + 
            ' ORDER BY Value__c ASC ' +
            ' LIMIT 1000';
        
        
        List<Price__c> prices = (List<Price__c>)Database.query(query);
        filtrFlight = prices;
    }
    
    public void bookFlight() {
        ApexPages.getMessages().clear();
        
        if (this.searchFlight.DateFrom__c > this.searchFlight.DateTo__c) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Date From can not be greater than Date To'
                )
            );
            return;
        }
        
        if (this.searchFlight.Flight__c == NULL && this.searchFlight.Addon__c == NULL || this.searchFlight.DateFrom__c == NULL || this.searchFlight.DateTo__c == NULL) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return;
        }
        
        List<String> condition = new List<String>();
        
        Id flightId = this.searchFlight.Flight__c;
        Id addonId = this.searchFlight.Addon__c;
        Date dateFrom = this.searchFlight.DateFrom__c;
        Date dateTo = this.searchFlight.DateTo__c;
        if (flightId != null && addonId == null) {
            condition.add('Flight__c = :flightId');
        } else if (flightId == null && addonId != null) {
            condition.add('Addon__c = :addonId');
        } else if (flightId != null && addonId != null) {
            condition.add('Flight__c = :flightId AND Addon__c = :addonId');
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
        Integer allocation = this.searchFlight.DateFrom__c.daysBetween(this.searchFlight.DateTo__c) + 1;
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