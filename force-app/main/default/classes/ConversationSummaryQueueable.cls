public class ConversationSummaryQueueable implements Queueable {
    private List<Id> threadIds;

    public ConversationSummaryQueueable(List<Id> threadIds) {
        this.threadIds = threadIds;
    }

    public void execute(QueueableContext context) {
        List<Message__c> messages = [
            SELECT
                CRM_Thread__c,
                CRM_Sent_Datetime_Formula__c,
                CRM_Message_Text__c,
                CRM_Type__c,
                CRM_Thread_Type__c,
                CRM_Event_Type__c,
                CRM_External_Message__c,
                CRM_From_First_Name__c,
                CRM_From_Ident_Formula__c
            FROM Message__c
            WHERE CRM_Thread__c IN :threadIds
            ORDER BY CRM_Sent_Datetime_Formula__c DESC
        ];

        if (messages.isEmpty()) {
            return;
        }

        Map<Id, List<String>> threadSummaries = new Map<Id, List<String>>();
        Map<Id, Datetime> latestMessageDates = new Map<Id, Datetime>();

        List<String> summaryText = new List<String>();
        for (Message__c msg : messages) {
            String messageText = msg.CRM_Message_Text__c;

            if (msg.CRM_Type__c == 'Event') {
                if (msg.CRM_Event_Type__c == 'END_OF_CHAT') {
                    messageText = 'Samtalen ble avsluttet';
                } else if (msg.CRM_Event_Type__c == 'QUEUE_TRANSFER' || msg.CRM_Event_Type__c == 'UNIT_TRANSFER') {
                    messageText = 'Samtalen er overført til avdeling ' + msg.CRM_Message_Text__c;
                }
            }

            String senderName = msg.CRM_External_Message__c
                ? msg.CRM_From_First_Name__c
                : (String.isBlank(msg.CRM_From_Ident_Formula__c)
                      ? ''
                      : msg.CRM_From_First_Name__c + ' (' + msg.CRM_From_Ident_Formula__c + ')');

            String formattedMessage =
            '<p><b>' + msg.CRM_Sent_Datetime_Formula__c + '</b></p>' +
            '<p>' + messageText + '</p>' +
            '<p>' + senderName + '</p><br>';

            if (!threadSummaries.containsKey(msg.CRM_Thread__c)) {
                threadSummaries.put(msg.CRM_Thread__c, new List<String>{formattedMessage});
            } else {
                threadSummaries.get(msg.CRM_Thread__c).add(formattedMessage);
            }

            // Track latest message datetime (skip if event is END_OF_CHAT/JOURNAL and thread type is STO/BTO)
            if ((msg.CRM_Event_Type__c == 'END_OF_CHAT' || msg.CRM_Event_Type__c == 'JOURNAL') && (msg.CRM_Thread_Type__c == 'STO' || msg.CRM_Thread_Type__c == 'BTO')) {
                continue;
            }
            latestMessageDates.put(msg.CRM_Thread__c, msg.CRM_Sent_Datetime_Formula__c);
        }

        List<Thread__c> threadsToUpdate = new List<Thread__c>();
        for (Id threadId : threadSummaries.keySet()) {
            Thread__c threadToUpdate = new Thread__c(
                Id = threadId,
                CRM_Conversation_Summary__c = String.join(threadSummaries.get(threadId), '')
            );
            if (latestMessageDates.containsKey(threadId)) {
                threadToUpdate.CRM_Latest_Message_Datetime__c = latestMessageDates.get(threadId);
            }
            threadsToUpdate.add(threadToUpdate);
        }

        if (!threadsToUpdate.isEmpty()) {
            update threadsToUpdate;
        }
    }
}
