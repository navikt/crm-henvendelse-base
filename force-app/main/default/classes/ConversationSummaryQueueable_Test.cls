@isTest
private class ConversationSummaryQueueable_Test {
    @isTest
    static void ConversationSummaryQueueableHelperTest() {
        Thread__c thread = new Thread__c();
        insert thread;

        List<Message__c> messages = new List<Message__c>{
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = 'test'),
            new Message__c(CRM_Thread__c = thread.Id, CRM_Message_Text__c = '123'),
            new Message__c(
                CRM_Thread__c = thread.Id,
                CRM_Type__c = 'Event',
                CRM_Event_Type__c = 'QUEUE_TRANSFER',
                CRM_Message_Text__c = 'event'
            ),
            new Message__c(
                CRM_Thread__c = thread.Id,
                CRM_Type__c = 'Event',
                CRM_Event_Type__c = 'JOURNAL',
                CRM_Message_Text__c = 'Journal'
            ),
            new Message__c(
                CRM_Thread__c = thread.Id,
                CRM_Type__c = 'Event',
                CRM_Event_Type__c = 'END_OF_CHAT',
                CRM_From_Ident__c = 'ABC123',
                CRM_Message_Text__c = 'end'
            )
        };
        insert messages;

        Test.startTest();
        ConversationSummaryQueueableHelper.runQueueable(new List<Id>{ thread.Id });
        Test.stopTest();

        thread = [SELECT CRM_Conversation_Summary__c FROM Thread__c WHERE Id = :thread.Id LIMIT 1];
        Assert.isFalse(String.isBlank(thread.CRM_Conversation_Summary__c), 'Expected summary to be populated');
        Assert.isTrue(thread.CRM_Conversation_Summary__c.contains('123'), 'Expected summary to contain input text');
    }
}
