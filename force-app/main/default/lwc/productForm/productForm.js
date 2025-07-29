import { LightningElement, track, wire, api } from 'lwc';
import getProductTypes from '@salesforce/apex/ProductTableController.getProductTypes';

export default class ProductForm extends LightningElement {
    @api action = 'close';
    @api initialData = {};
    @track formData = {};
    @track errorMsg = null;
    @track availableTypes = [];

    @wire(getProductTypes)
    wiredTypes({ error, data }) {
        if (data) {
            this.availableTypes = data.map(type => ({
                label: type,
                value: type
            }));
        } else if (error) {
            console.error('Error while loading types : ', error);
        }
    }

    connectedCallback() {
        this.formData = { ... this.initialData };
    }

    handleInput(event) {
        const field = event.target.dataset.field;
        this.formData[field] = event.target.value;
    }

    cancel() {
        this.action = 'close';
        this._clearFormAndError();
        this._dispatch();
    }

    complete() {
        if (this._inputIsInvalid()) {
            this.errorMsg = 'Please fill in the required fields (amount, price must be greater than 0 and releaseDate must be <= today).';
            return;
        }
        this._dispatch();
        this._clearFormAndError();
    }

    _dispatch() {
        this.dispatchEvent(new CustomEvent('complete', {
            detail: {
                action: this.action,
                data: this.formData
            }
        }));
    }

    _inputIsInvalid() {
        const name = this.formData.Name;
        const amount = this.formData.Amount__c;
        const price = parseFloat(this.formData.Price__c);
        const type = this.formData.ProductType__c;
        const releaseDate = this.formData.ReleaseDate__c;
        const todayDate = new Date();
        todayDate.setHours(0, 0, 0, 0);
        return !name
            || isNaN(amount) || amount < 0
            || isNaN(price) || price <= 0
            || !type
            || !releaseDate || new Date(releaseDate) > todayDate;
    }

    _clearFormAndError() {
        this.formData = {};
        this.errorMsg = null;
    }
}