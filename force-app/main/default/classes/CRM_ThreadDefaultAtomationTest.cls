@isTest
public without sharing class CRM_ThreadDefaultAtomationTest {
    @isTest
    static void typeFieldSetOnBeforeInsert() {
        Thread__c thread = new Thread__c(CRM_Thread_Type__c = 'DEFAULT');

        Test.startTest();
        insert thread;
        Test.stopTest();

        Thread__c updatedThread = [
            SELECT Id, CRM_Thread_Type__c, CRM_Type__c
            FROM Thread__c
            WHERE Id = :thread.Id
        ];
        System.assertEquals(updatedThread.CRM_Thread_Type__c, updatedThread.CRM_Type__c, 'Could not set TYpe equal to Thread Type');
        System.assertEquals('DEFAULT', updatedThread.CRM_Type__c, 'Could not set Type correctly');
    }
    
}
