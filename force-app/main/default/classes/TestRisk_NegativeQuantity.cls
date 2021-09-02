@isTest
private class TestRisk_NegativeQuantity {

        static testMethod void myUnitTest() {
        // TO DO: implement unit test

            Test.starttest();
            Account acc = new Account();
            acc.Name='NewAcc';
            insert acc;

            Opportunity opp = new Opportunity();
            opp.Name='NewOpp';
            opp.AccountId=acc.Id;
            opp.StageName='Prospecting';
            opp.CloseDate=Date.today().addDays(10);
            insert opp;

            Product2 Prod =  new Product2();
            Prod.Name='NewProd';
            Prod.IsActive=True;
            insert Prod;
            
            Opportunity oppt = [select Id, Name, Pricebook2Id from Opportunity where Name=:'NewOpp'];
            system.debug('-----Oppt Pricebook---'+oppt.Pricebook2Id);
            
            PricebookEntry stdpbe = new PricebookEntry();
            stdpbe.Product2Id=Prod.Id;
            stdpbe.IsActive=True;
            stdpbe.UnitPrice=70;
            stdpbe.Pricebook2Id = Test.getStandardPricebookId();
            stdpbe.UseStandardPrice=false;
            insert stdpbe;

            PricebookEntry pbe = new PricebookEntry();
            pbe.Product2Id=Prod.Id;
            pbe.IsActive=True;
            pbe.UnitPrice=70;
            pbe.Pricebook2Id = oppt.Pricebook2Id;
            pbe.UseStandardPrice=false;
            insert pbe;

            OpportunityLineItem opli = new OpportunityLineItem();
            opli.UnitPrice = 57;
            opli.Quantity = 12;
            opli.OpportunityId=opp.Id;
            opli.PricebookEntryId=pbe.id;
            insert opli;
            Test.stoptest();

        }
}