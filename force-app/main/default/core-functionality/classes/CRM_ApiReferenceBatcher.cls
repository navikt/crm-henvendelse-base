public without sharing class CRM_ApiReferenceBatcher implements Database.Batchable<SObject> {
    public CRM_ApiReferenceBatcher(Boolean threadRefSwitch, String query) {
        this.threadRefSwitch = threadRefSwitch;
        this.query = query;
    }

    public CRM_ApiReferenceBatcher(String query) {
        this.query = query;
    }
    private final String query;
    private final Boolean threadRefSwitch;

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        for (sobject sObj : scope) {
            if (threadRefSwitch == true) {
                String henvBehId = (String) sObj.get('CRM_Henvendelse_BehandlingsId__c');
                sObj.put('CRM_API_Reference__c', henvBehId);
            } else {
                sObj.put('CRM_API_Reference__c', CRM_ReferenceUtil.generateReference(sObj));
            }
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC) {
    }
}
