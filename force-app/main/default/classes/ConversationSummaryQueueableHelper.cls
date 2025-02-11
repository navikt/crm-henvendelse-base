public class ConversationSummaryQueueableHelper {
    @InvocableMethod(label='Run Conversation Summary Queueable' description='Starts the queueable job for a given Thread Id')
    public static void runQueueable(List<Id> threadIds) {
        if (threadIds.isEmpty()) {
            return;
        }

        System.enqueueJob(new ConversationSummaryQueueable(threadIds[0]));
    }
}
