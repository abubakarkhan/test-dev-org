/**
 * Created by Abu on 8/11/2022.
 */

trigger TransactionItemTrigger on Transaction_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    //TO DO: Implement a trigger framework

    //handle after insert
    if(Trigger.isAfter && Trigger.isInsert){
        TriggerHandler_TransactionItem.handleAfterInsert(Trigger.newMap, Trigger.oldMap);
    }

}