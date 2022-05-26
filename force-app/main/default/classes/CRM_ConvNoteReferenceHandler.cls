public without sharing class CRM_ConvNoteReferenceHandler extends MyTriggers {
    public override void onBeforeInsert() {
        for (Conversation_Note__c convNote : (List<Conversation_Note__c>) Records) {
            String apiRef = CRM_ReferenceUtil.generateReference(convNote);
            convNote.CRM_API_Reference__c = apiRef;
            if (String.isBlank(convNote.CRM_Henvendelse_BehandlingskjedeId__c)) {
                //If the CRM_Henvendelse_BehandlingskjedeId__c is not blank this is created as a follow up conv note on the same chain, else populate with its own ref
                convNote.CRM_Henvendelse_BehandlingskjedeId__c = apiRef;
            }
        }
    }
}
