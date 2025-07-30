import { LightningElement, track } from 'lwc';
import getProducts from '@salesforce/apex/ProductTableController.getProducts';
import deleteProduct from '@salesforce/apex/ProductTableController.deleteProduct';
import editProduct from '@salesforce/apex/ProductTableController.editProduct';
import createProduct from '@salesforce/apex/ProductTableController.createProduct';

export default class ProductTable extends LightningElement {
    _ACTIONS = {
        CREATE: 'create',
        EDIT: 'edit',
        DELETE: 'delete',
        SEARCH: 'search',
        ALL: 'all',
    };
    @track searchingParam = '';
    @track errorMsg = null;
    @track loading = false;
    @track products = [];
    @track isFormVisible = false;
    @track productToEdit = {};
    @track formAction = this._ACTIONS.CREATE;

    connectedCallback() {
        this._reloadProducts();
    }

    handleTableActions(event) {
        const action = event.target?.dataset?.action || event.detail?.value;
        switch (action) {
            case this._ACTIONS.EDIT:
                this.formAction = this._ACTIONS.EDIT;
                this._openForm(event.target?.dataset?.id);
                break;
            case this._ACTIONS.CREATE:
                this.formAction = this._ACTIONS.CREATE;
                this._openForm();
                break;
            case this._ACTIONS.DELETE:
                this._deleteProductById(event.target?.dataset?.id);
                break;
            case this._ACTIONS.ALL:
                this._searchByName();
                break;
            case this._ACTIONS.SEARCH:
                if (event.key === 'Enter') {
                    this._searchByName(event.target?.value);
                }
                break;
        }
    }

    handleFormEvent(event) {
        const { action, data } = event.detail;
        switch (action) {
            case this._ACTIONS.CREATE:
                this._createProduct(data);
                break;
            case this._ACTIONS.EDIT:
                this._editProduct(data);
                break;
        }
        this._closeForm();
    }

    _searchByName(param = '') {
        this.searchingParam = param;
        this._reloadProducts();
    }

    _reloadProducts() {
        this._performRequest(
            () => getProducts({ searchName: this.searchingParam }),
            products => this.products = products
        );
    }

    _deleteProductById(id) {
        this._performRequest(
            () => deleteProduct({ productId: id }),
            () => this._reloadProducts()
        );
    }

    _createProduct(data) {
        this._performRequest(
            () => createProduct({ newProduct: data }),
            () => this._reloadProducts()
        );
    }

    _editProduct(data) {
        this._performRequest(
            () => editProduct({ editedProduct: data }),
            () => this._reloadProducts()
        );
    }

    _performRequest(operation, thenOperation) {
        this.loading = true;
        operation()
            .then(result => thenOperation(result))
            .catch(error => console.error('Error while performing operation: ', error))
            .finally(() => this.loading = false);
    }

    _openForm(id = null) {
        if (id) {
            this.productToEdit = this.products.find(product => product.Id === id);
        }
        this.isFormVisible = true;
    }

    _closeForm() {
        this.isFormVisible = false;
        this.productToEdit = {};
        this.action = this._ACTIONS.CREATE;
    }
}