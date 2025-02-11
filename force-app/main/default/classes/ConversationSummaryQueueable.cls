public class ConversationSummaryQueueable implements Queueable {
    private Id threadId;

    public ConversationSummaryQueueable(Id threadId) {
        this.threadId = threadId;
    }

    public void execute(QueueableContext context) {
        List<Message__c> messages = [
            SELECT
                CRM_Sent_Datetime_Formula__c,
                CRM_Message_Text__c,
                CRM_Type__c,
                CRM_Event_Type__c,
                CRM_External_Message__c,
                CRM_From_First_Name__c,
                CRM_From_Ident_Formula__c
            FROM Message__c
            WHERE CRM_Thread__c = :threadId
            ORDER BY CRM_Sent_Datetime_Formula__c DESC
        ];
        if (messages.isEmpty()) {
            return;
        }

        List<String> summaryText = new List<String>();
        for (Message__c msg : messages) {
            String messageText;

            if (msg.CRM_Type__c == 'Event') {
                if (msg.CRM_Event_Type__c == 'END_OF_CHAT') {
                    messageText = 'Samtalen ble avsluttet';
                } else if (msg.CRM_Event_Type__c == 'QUEUE_TRANSFER' || msg.CRM_Event_Type__c == 'UNIT_TRANSFER') {
                    messageText = 'Samtalen er overført til avdeling ' + msg.CRM_Message_Text__c;
                } else {
                    messageText = msg.CRM_Message_Text__c;
                }
            } else {
                messageText = msg.CRM_Message_Text__c;
            }

            String senderName = msg.CRM_External_Message__c
                ? msg.CRM_From_First_Name__c
                : (String.isBlank(msg.CRM_From_Ident_Formula__c)
                      ? ''
                      : msg.CRM_From_First_Name__c + ' (' + msg.CRM_From_Ident_Formula__c + ')');

            summaryText.add(
                '<p><b>' +
                    msg.CRM_Sent_Datetime_Formula__c +
                    '</b></p>' +
                    '<p>' +
                    messageText +
                    '</p>' +
                    '<p>' +
                    senderName +
                    '</p><br>'
            );
        }

        String conversationSummary = String.join(summaryText, '');

        if (!messages.isEmpty()) {
            Thread__c threadToUpdate = new Thread__c(
                Id = threadId,
                CRM_Conversation_Summary__c = conversationSummary,
                CRM_Latest_Message_Datetime__c = messages[0].CRM_Sent_Datetime_Formula__c
            );
            update threadToUpdate;
        }
    }
}
