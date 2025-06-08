trigger AccountTrigger on Account (after update) {
    AccountTriggerHandler handler = new AccountTriggerHandler();

    if(Trigger.isAfter) {
        if(Trigger.isUpdate) {
            handler.isAfterUpdate(Trigger.new);
        }
    }
}