public class BookFlightController {
	public BookedFlight__c searchFlight { get; set; }
    public String cityFromValue { get; set; }
    public String cityToValue { get; set; }
    public String dateFromValue { get; set; }
    public String dateToValue { get; set; }
    public String tableData { get; set; }
    public Map<String, List<Price__c>> tableDataMap { get; set; }
    public List<Price__c> addonPrices { get; set; }
    public String foodValue { get; set; }
    public String pillowValue { get; set; }
    public String plaidValue { get; set; }
    
    public BookFlightController() {
        this.searchFlight = new BookedFlight__c();
        this.cityFromValue = '';
        this.cityToValue = '';
        this.dateFromValue = '';
        this.dateToValue = '';
        this.tableData = '';
        this.tableDataMap = new Map<String, List<Price__c>>();
        this.addonPrices = [SELECT Addon__r.Name, Name, Value__c FROM Price__c WHERE Addon__r.Name != NULL];
        this.foodValue = '';
        this.pillowValue = '';
        this.plaidValue = '';
    }
 
    public void searchFlights() {

        ApexPages.getMessages().clear();

        if (cityFromValue.equals('') && cityToValue.equals('') || dateFromValue.equals('') || dateToValue.equals('')) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return;
        }

        String cityFrom = cityFromValue;
        String cityTo = cityToValue;
        Date dateFrom = Date.valueOf(dateFromValue);
        Date dateTo = Date.valueOf(dateToValue);
        
        if (dateFrom > dateTo) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR, 
                    'Date From can not be greater than Date To'
                )
            );
            return;
        }
      

        List<String> condition = new List<String>();

        if (cityFrom != null && cityTo != null) {
            condition.add('Flight__r.CityFrom__c = :cityFrom AND Flight__r.CityTo__c = :cityTo');
        } 
        
        String query = 'SELECT Flight__r.CityFrom__c, Flight__r.CityTo__c, DateFrom__c, DateTo__c, Value__c ' + 
            ' FROM Price__c ' + 
            ' WHERE ' + String.join(condition, ' AND ') + 
            ' AND DateFrom__c <= :dateFrom ' +
            ' AND DateTo__c >= :dateTo ' + 
            ' ORDER BY Value__c ASC ' +
            ' LIMIT 1000';
        
        List<Price__c> pricesFlights = (List<Price__c>)Database.query(query);

        tableDataMap = new Map<String, List<Price__c>> {};
        tableDataMap.put('Flights', pricesFlights);
        tableData = JSON.serialize(tableDataMap);
    }

    public PageReference bookFlight() {
        
        String cityFrom = cityFromValue;
        String cityTo = cityToValue;
        Date dateFrom = Date.valueOf(dateFromValue);
        Date dateTo = Date.valueOf(dateToValue);
        Integer numberOfFlights = 0;

        List<String> condition = new List<String>();

        if (cityFrom != null && cityTo != null) {
            condition.add('Flight__r.CityFrom__c = :cityFrom AND Flight__r.CityTo__c = :cityTo');
        }
        
        String query = 'SELECT Flight__r.isBooked__c, Flight__r.CityFrom__c, Flight__r.CityTo__c, DateFrom__c, DateTo__c, Value__c ' + 
            ' FROM Price__c ' + 
            ' WHERE ' + String.join(condition, ' AND ') + 
            ' AND DateFrom__c <= :dateFrom ' +
            ' AND DateTo__c >= :dateTo ' + 
            ' ORDER BY Value__c ASC ' +
            ' LIMIT 1000';
        
        List<Price__c> pricesFlights = (List<Price__c>)Database.query(query);
        numberOfFlights = pricesFlights.size();
        
        Price__c flightPrice = new Price__c();
        
        for (Price__c price : pricesFlights) {
            if (price.Flight__c != null) {
                flightPrice = price;
            }
        }
        
        Decimal flightAmount = 0.0;
        Integer allocation = dateFrom.daysBetween(dateTo) + 1;

        if (flightPrice.Id != null) {
            flightAmount = flightPrice.Value__c * allocation;
        } 

        Flight__c bookedFlight = new Flight__c();
        bookedFlight = pricesFlights[numberOfFlights-1].Flight__r;
        bookedFlight.isBooked__c = true;
        
        insert new BookedFlight__c(
            Flight__c = pricesFlights[numberOfFlights-1].Flight__c,
            DateFrom__c = dateFrom,
            DateTo__c = dateTo,
            TotalPrice__c = flightAmount
        );

        return Page.pageAddon;
    }

    public PageReference goToAddonPage() {

        if (cityFromValue.equals('') && cityToValue.equals('') || dateFromValue.equals('') || dateToValue.equals('')) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.ERROR, 
                    'Fields can not be empty'
                )
            );
            return Page.pageFlight;
        }

        return Page.pageAddon;
    }

    public void bookAddon() {
        String condition = '';

        if (foodValue != '' && pillowValue != '' && plaidValue != '') {
            condition = 'Addon__r.Name = :foodValue OR Addon__r.Name = :pillowValue OR Addon__r.Name = :plaidValue';
        } else if (foodValue != '' && pillowValue != '') {
            condition = 'Addon__r.Name = :foodValue OR Addon__r.Name = :pillowValue';
        } else if (pillowValue != '' && plaidValue != '') {
            condition = 'Addon__r.Name = :pillowValue OR Addon__r.Name = :plaidValue';
        } else if (foodValue != '' && plaidValue != '') {
            condition = 'Addon__r.Name = :foodValue OR Addon__r.Name = :plaidValue';
        } else if (foodValue != '') {
            condition = 'Addon__r.Name = :foodValue';
        } else if (plaidValue != '') {
            condition = 'Addon__r.Name = :plaidValue';
        } else if (pillowValue != '') {
            condition = 'Addon__r.Name = :pillowValue';
        }

        String query = 'SELECT Addon__c, Name, Value__c FROM Price__c WHERE ' + condition + ' ';
        List<Price__c> selectAddons = (List<Price__c>) Database.query(query);

        //update BookedFlight__c with Addons
        //number of addons ???
        
    }

    public PageReference goToFlightPage() {
        return Page.pageFlight;
    }
}