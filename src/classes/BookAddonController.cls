public class BookAddonController {
	public List<Price__c> addonPrices { get; set; }
    public String foodValue { get; set; }
    public String pillowValue { get; set; }
    public String plaidValue { get; set; }

    public BookAddonController() {
    	this.addonPrices = [SELECT Addon__r.Name, Name, Value__c FROM Price__c WHERE Addon__r.Name != NULL];
        this.foodValue = '';
        this.pillowValue = '';
        this.plaidValue = '';
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

        String query = 'SELECT Addon__c, Name, Value__c FROM Price__c WHERE ' + condition + ' AND Flight__c = NULL';
        List<Price__c> selectAddons = (List<Price__c>) Database.query(query);
        
        ID flight = ApexPages.CurrentPage().getParameters().get('id');

        for (Integer i = 0; i < selectAddons.size(); i++) {
           insert new FlightAddon__c(
                Flight__c = flight,
                Addon__c = selectAddons[i].Addon__c
            );
        }
        
    }

    public PageReference goToFlightPage() {
        return Page.pageFlight;
    }
}