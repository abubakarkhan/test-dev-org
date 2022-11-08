/**
 * Created by Abu on 8/11/2022.
 */

public with sharing class TriggerHandler_TransactionItem {

    public static void handleAfterInsert(Map<Id, Transaction_Item__c> newMap, Map<Id, Transaction_Item__c> oldMap){
        queueSendTransactionData(newMap);
    }

    //Call queueable service to send out transaction data to external service asynchronously
    private static void queueSendTransactionData(Map<Id, Transaction_Item__c> newMap){
        if(!Test.isRunningTest()) System.enqueueJob(new TransactionQueueable(newMap));
    }

}