@isTest
public class CRM_ConvNoteReferenceHandler_Test {
    @isTest
    static void testReferenceGeneration() {
        Test.startTest();
        CRM_HENV_Base_TestDataFactory.createRecord(new Conversation_Note__c());
        Test.stopTest();

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Conversation_Note__c
                WHERE CRM_API_Reference__c != NULL AND CRM_Henvendelse_BehandlingskjedeId__c != NULL
            ]
        );
    }

    @isTest
    static void testChainIdPersistence() {
        Test.startTest();
        CRM_HENV_Base_TestDataFactory.createRecord(
            new Conversation_Note__c(CRM_Henvendelse_BehandlingskjedeId__c = '123TEST')
        );
        Test.stopTest();

        System.assertEquals(
            1,
            [
                SELECT COUNT()
                FROM Conversation_Note__c
                WHERE CRM_API_Reference__c != NULL AND CRM_Henvendelse_BehandlingskjedeId__c = '123TEST'
            ]
        );
    }
}
