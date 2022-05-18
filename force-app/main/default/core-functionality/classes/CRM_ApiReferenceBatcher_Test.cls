@isTest
public class CRM_ApiReferenceBatcher_Test {

    @isTest
    static void testThreadRefSwitch() {
        String query = 'SELECT Id, CRM_API_Reference__c, CRM_Henvendelse_BehandlingsId__c FROM Thread__c';
        CRM_ApiReferenceBatcher batcher = new CRM_ApiReferenceBatcher(true, query);

        Test.startTest();
        Database.executeBatch(batcher);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM Thread__c WHERE CRM_API_Reference__c = '123TEST']);
    }
}
