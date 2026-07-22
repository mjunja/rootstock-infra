# =============================================================================
# App Variables
# =============================================================================

variable "app_name" {
  description = "The name of the Heroku app"
  type        = string
  default     = "rootf-dev"
}

variable "region" {
  description = "Heroku region"
  type        = string
  default     = "us"
}

variable "stack" {
  description = "Heroku stack"
  type        = string
  default     = "heroku-22"
}

variable "team_name" {
  description = "Heroku team that owns the app"
  type        = string
  default     = "rootstocksoftware"
}

# =============================================================================
# GitHub Integration & Deployment Branch
# =============================================================================

variable "github_repo" {
  description = "GitHub repository in 'owner/repo' format"
  type        = string
  default     = "rootstockmfg/hkrdocs"
}

variable "deploy_branch" {
  description = "Git branch connected to this app (auto-deploy disabled)"
  type        = string
  default     = "qa-build"
}

variable "auto_deploy" {
  description = "Enable auto-deploy on push to deploy_branch"
  type        = bool
  default     = false
}

variable "wait_for_ci" {
  description = "Wait for CI to pass before auto-deploying"
  type        = bool
  default     = false
}

# =============================================================================
# Dyno Configuration
# =============================================================================

variable "rfworker_dyno_size" {
  description = "Dyno size for the rfworker process"
  type        = string
  default     = "standard-2x"
}

variable "rfworker_dyno_quantity" {
  description = "Number of rfworker dynos"
  type        = number
  default     = 0
}

# =============================================================================
# Config Vars (non-sensitive)
# =============================================================================

variable "both_mongos" {
  description = "BOTH_MONGOS config var"
  type        = string
  default     = "true"
}

variable "dbfield_id" {
  description = "DBFieldId config var"
  type        = string
  default     = "rstk__formula_invoice__c,rstk__soinv_invoiceno__c,rstk__soinv_invoice__c,rstk__sohdr_order__c,Name"
}

variable "default_mongodb" {
  description = "Default MongoDB provider"
  type        = string
  default     = "ORMONGO"
}

variable "i_am_oneoff" {
  description = "I_AM_ONEOFF config var"
  type        = string
  default     = "true"
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "DEBUG"
}

variable "ormongo_region" {
  description = "ObjectRocket MongoDB region"
  type        = string
  default     = "IAD"
}

variable "org_id" {
  description = "Org_ID config var"
  type        = string
  default     = "00D36000001Ee5MEAS,aCT1Q0000004d64WAA,00D410000011HE0EAM"
}

variable "sforce_namespace" {
  description = "Salesforce package namespace"
  type        = string
  default     = "DOX__"
}

variable "soinvoice" {
  description = "SOInvoice config var"
  type        = string
  default     = "rstk__soinv_invoice__c"
}

variable "so_number" {
  description = "SO_Number config var"
  type        = string
  default     = "rstk__sohdr_order__c"
}

variable "sales_invoice_formula" {
  description = "SalesInvoiceFormula config var"
  type        = string
  default     = "rstk__formula_invoice__c"
}

variable "sales_invoice_no" {
  description = "SalesInvoiceNo config var"
  type        = string
  default     = "rstk__soinv_invoiceno__c"
}

variable "use_single_thread_model" {
  description = "USE_SINGLE_THREAD_MODEL config var"
  type        = string
  default     = "false"
}

variable "unique_filed" {
  description = "UniqueFiled config var"
  type        = string
  default     = "Invoice_Number,SO_Number,Order_No,Order_Number,Invoice_number"
}

variable "doc_mapped_field_names" {
  description = "doc_mapped_field_names config var"
  type        = string
  default     = "Invoice_Number"
}

variable "is_loging" {
  description = "isLoging config var"
  type        = string
  default     = "true"
}

variable "mapped_field_names" {
  description = "mapped_field_names config var"
  type        = string
  default     = "rstk__soinv_order__r.Name,rstk__soinv_invoice__c,rstk__soinv_invdate__c,rstk__soinv_order__r.rstk__sohdr_custpo__c,Quantity_For_Display__c,rstk__soinvline_extamount__c,rstk__soinv_total__c,rstk__soinv_freightamt__c,rstk__soinv_taxovramt__c,rstk__soinv_grandtotal__c,Credits_and_Prepayments__c,rstk__soinvline_qty__c,rstk__soinvline_line__r.rstk__soshipline_qtyship__c,rstk__soinvline_uom__r.rstk__syuom_uom__c,rstk__soinvline_price__c,rstk__soinv_totalppya__c,Invoice_Total_Due__c,rstk__soinvline_line__r.rstk__soshipline_line__r.rstk__soline_pricecalcbase__c,Total_with_Credits_and_Prepayments__c,rstk__soinvline_line__r.rstk__soshipline_line__r.rstk__soline_pricecalcdisc__c,Price_For_Display__c,rstk__soinv_invoiceno__c,rstk__soinvline_prod__r.Name,rstk__soinvline_uom__r.Name,rstk__soinvline_line__r.Name,rstk__soinvline_pricehc__c,rstk__soinvline_discpct__c,rstk__soinvline_taxexempt__c,r,rstk__soinv_taxamt__c,rstk__sohdr_order__c,rstk__soline_qtyorder__c,rstk__soinvline_prod__r.rstk__soprod_prod__c,rstk__soinvline_prod__r.rstk__soprod_descr__c,rstk__soinvline_extamount_rpt__c,Name,Qty_Ordered__c,Qty_Pre_paid__c,Product__c,Description__c,Unit_Price__c,Amount_Pre_paid__c,rstkf__arapplic_amthome__c,rstk__soppya_amtappl__c,rstkf__arinvtxn_tranid__c,rstkf__arinvtxn_docno__c,rstkf__arinvtxn_trantype__c,rstkf__arinvtxn_trandate__c,rstk__sohdr_orderdate__c,Actual_Skid_Count__c,rstk__soline_prod__r.Name,rstk__soline_uom__r.Name,QTY_Remaining__c,rstk__icdmdpickloc_locqty__c,rstk__icdmdpickloc_suggestedqty__c,rstk__sopickh_picklistno__c,rstk__sopickh_sohdr__r.Name,rstk__sopickh_sohdr__r.rstk__sohdr_orderdate__c,rstk__icdmdpickloc_compitem__r.Name,rstk__icdmdpickloc_compitem__r.rstk__icitem_invuom__r.Name,rstk__icdmdpickloc_dmdqtyoutstdg__c,\nrstk__soinv_total_rpt__c,rstk__soinv_grandtotal_rpt__c,rstk__formula_invoice__c,MLC_Outstanding_Balance__c,rstk__sohdr_otype__r.rstk__sootype_desc__c,CreatedDate,Picking_Loc_Formula_For_Templates__c,Sum_of_Qty_Ordered__c,rstk__sohdr_totalweight__c,Total_Tons_Formula__c,rstk__sohdr_otype__r.rstk__sootype_ordtype__c,rstk__soline_prod__r.rstk__soprod_prod__c,rstk__soline_prod__r.rstk__soprod_descr__c,rstk__soline_wocstordno__r.Batch_Order__r.Name,rstk__soline_prod__r.rstk__soprod_slsuom__r.rstk__syuom_uom__c,Order_Invoice__r.Sack_Trailer__c,Order_Invoice__r.Bulk_Trailer__c,Order_Invoice__r.Load__c,Order_Invoice__r.Stop__c,rstk__soline_line__c,rstk__soline_uom__r.rstk__syuom_uom__c,rstk__soline_price__c,rstk__soline_discpct__c,rstk__soline_ext__c,rstk__soline_taxexempt__c,rstk__sohdr_ordertotal__c,rstk__sohdr_totamt__c,Amount__c,Gross_Amount__c"
}

variable "template_id" {
  description = "templateId config var"
  type        = string
  default     = "aCT1Q0000004d64WAA,aHE6S000000TNLJWA4,aB24M000000002hSAA,aCT1Q000000CwIXWA0,aCTHp000000CwKsOAK,aBq1K0000004LYbSAM"
}

# =============================================================================
# Config Vars (sensitive - set via env vars or .tfvars)
# =============================================================================

variable "heroku_password" {
  description = "Heroku account password"
  type        = string
  sensitive   = true
}

variable "heroku_username" {
  description = "Heroku account username"
  type        = string
  sensitive   = true
}

variable "mongolab_uri" {
  description = "MongoLab connection URI"
  type        = string
  sensitive   = true
}

variable "ormongo_dbname" {
  description = "ObjectRocket MongoDB database name"
  type        = string
  sensitive   = true
}

variable "ormongo_password" {
  description = "ObjectRocket MongoDB password"
  type        = string
  sensitive   = true
}

variable "ormongo_rs_url" {
  description = "ObjectRocket MongoDB replica set URL"
  type        = string
  sensitive   = true
}

variable "ormongo_url" {
  description = "ObjectRocket MongoDB URL"
  type        = string
  sensitive   = true
}

variable "ormongo_username" {
  description = "ObjectRocket MongoDB username"
  type        = string
  sensitive   = true
}

variable "sforce_client_key" {
  description = "Salesforce connected app client key"
  type        = string
  sensitive   = true
}

variable "sforce_client_secret" {
  description = "Salesforce connected app client secret"
  type        = string
  sensitive   = true
}

variable "dburl" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
}
