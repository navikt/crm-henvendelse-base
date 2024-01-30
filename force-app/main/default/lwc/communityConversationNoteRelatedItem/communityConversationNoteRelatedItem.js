import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getDateTimeFormat } from '@salesforce/i18n-service';

export default class CommunityConversationNoteRelatedItem extends NavigationMixin(LightningElement) {
    @api note;
    url;

    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.note.Id,
                objectApiName: 'Conversation_Note__c',
                actionName: 'view'
            }
        }).then((url) => {
            this.url = url;
        });
    }

    get date() {
        if (this.note.CRM_Date_Time_Registered__c) {
            const inputs = this.note.CRM_Date_Time_Registered__c.split('T');
            const dateTable = inputs[0].split('-');
            const timeTable = inputs[1].split(':');

            const fullDate = new Date(
                Date.UTC(dateTable[0], dateTable[1] - 1, dateTable[2], timeTable[0], timeTable[1])
            );
            return ' fra ' + getDateTimeFormat('no-no', { dateStyle: 'long', timeStyle: 'short' }).format(fullDate);
        }
        return '';
    }

    get label() {
        return 'Klikk her for å se referat' + this.date;
    }
}
