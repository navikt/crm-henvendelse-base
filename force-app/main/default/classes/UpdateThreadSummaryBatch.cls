public class UpdateThreadSummaryBatch implements Database.Batchable<Thread__c>{

    public final String query;

    public UpdateThreadSummaryBatch() {
        query = 'SELECT Id FROM Thread__c WHERE CRM_Latest_Message_Datetime__c = LAST_N_DAYS:90 OR CRM_Latest_Message_Datetime__c = TODAY';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Thread__c> scope){
        for(Thread__c thread : scope){
            Map<String,Object> flowVars = new Map<String, Object>();
            flowVars.put('threadId', thread.Id);
            Flow.Interview.CRMHenvendelse_Thread_Subflow_RecalculateMessageSummary flow = new Flow.Interview.CRMHenvendelse_Thread_Subflow_RecalculateMessageSummary(flowVars);
            flow.start();
        }
    }

    public void finish(Database.BatchableContext BC){}
}
