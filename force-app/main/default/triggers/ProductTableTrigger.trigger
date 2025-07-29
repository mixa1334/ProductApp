trigger ProductTableTrigger on ProductTable__c (before insert, before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ProductTableTriggerHelper.processInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            ProductTableTriggerHelper.processUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}