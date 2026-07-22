# =============================================================================
# rootf-dev - Heroku Application
# =============================================================================
# Part of the "rootforms" pipeline, "development" stage.
# Mirrors the live Heroku app. Shared logic and common defaults live in the
# rstk-app module; only this app's specifics are set below.
# =============================================================================

module "app" {
  source = "../../../../modules/rstk-app"

  app_name       = "rootf-dev"
  pipeline_name  = "rootforms"
  # pipeline_stage defaults to "development"
  stack         = "heroku-22"  # differs from the module default

  # GitHub integration (live values)
  github_repo   = "rootstockmfg/hkrdocs"
  deploy_branch = "qa-build"
  auto_deploy   = false
  wait_for_ci   = false

  # Owned add-on
  papertrail_plan = "papertrail:choklad"

  # Dyno formation (currently scaled to 0)
  formations = {
    rfworker = { size = "standard-2x", quantity = 0 }
  }

  # Non-sensitive config vars. DEFAULT_MONGODB=ORMONGO comes from the module base.
  config_vars = {
    BOTH_MONGOS             = "true"
    DBFieldId               = "rstk__formula_invoice__c,rstk__soinv_invoiceno__c,rstk__soinv_invoice__c,rstk__sohdr_order__c,Name"
    I_AM_ONEOFF             = "true"
    LOG_LEVEL               = "DEBUG"
    Org_ID                  = "00D36000001Ee5MEAS,aCT1Q0000004d64WAA,00D410000011HE0EAM"
    SFORCE_NAMESPACE        = "DOX__"
    SOInvoice               = "rstk__soinv_invoice__c"
    SO_Number               = "rstk__sohdr_order__c"
    SalesInvoiceFormula     = "rstk__formula_invoice__c"
    SalesInvoiceNo          = "rstk__soinv_invoiceno__c"
    USE_SINGLE_THREAD_MODEL = "false"
    UniqueFiled             = "Invoice_Number,SO_Number,Order_No,Order_Number,Invoice_number"
    doc_mapped_field_names  = "Invoice_Number"
    isLoging                = "true"
    mapped_field_names      = "rstk__soinv_order__r.Name,rstk__soinv_invoice__c,rstk__soinv_invdate__c,rstk__soinv_order__r.rstk__sohdr_custpo__c,Quantity_For_Display__c,rstk__soinvline_extamount__c,rstk__soinv_total__c,rstk__soinv_freightamt__c,rstk__soinv_taxovramt__c,rstk__soinv_grandtotal__c,Credits_and_Prepayments__c,rstk__soinvline_qty__c,rstk__soinvline_line__r.rstk__soshipline_qtyship__c,rstk__soinvline_uom__r.rstk__syuom_uom__c,rstk__soinvline_price__c,rstk__soinv_totalppya__c,Invoice_Total_Due__c,rstk__soinvline_line__r.rstk__soshipline_line__r.rstk__soline_pricecalcbase__c,Total_with_Credits_and_Prepayments__c,rstk__soinvline_line__r.rstk__soshipline_line__r.rstk__soline_pricecalcdisc__c,Price_For_Display__c,rstk__soinv_invoiceno__c,rstk__soinvline_prod__r.Name,rstk__soinvline_uom__r.Name,rstk__soinvline_line__r.Name,rstk__soinvline_pricehc__c,rstk__soinvline_discpct__c,rstk__soinvline_taxexempt__c,r,rstk__soinv_taxamt__c,rstk__sohdr_order__c,rstk__soline_qtyorder__c,rstk__soinvline_prod__r.rstk__soprod_prod__c,rstk__soinvline_prod__r.rstk__soprod_descr__c,rstk__soinvline_extamount_rpt__c,Name,Qty_Ordered__c,Qty_Pre_paid__c,Product__c,Description__c,Unit_Price__c,Amount_Pre_paid__c,rstkf__arapplic_amthome__c,rstk__soppya_amtappl__c,rstkf__arinvtxn_tranid__c,rstkf__arinvtxn_docno__c,rstkf__arinvtxn_trantype__c,rstkf__arinvtxn_trandate__c,rstk__sohdr_orderdate__c,Actual_Skid_Count__c,rstk__soline_prod__r.Name,rstk__soline_uom__r.Name,QTY_Remaining__c,rstk__icdmdpickloc_locqty__c,rstk__icdmdpickloc_suggestedqty__c,rstk__sopickh_picklistno__c,rstk__sopickh_sohdr__r.Name,rstk__sopickh_sohdr__r.rstk__sohdr_orderdate__c,rstk__icdmdpickloc_compitem__r.Name,rstk__icdmdpickloc_compitem__r.rstk__icitem_invuom__r.Name,rstk__icdmdpickloc_dmdqtyoutstdg__c,\nrstk__soinv_total_rpt__c,rstk__soinv_grandtotal_rpt__c,rstk__formula_invoice__c,MLC_Outstanding_Balance__c,rstk__sohdr_otype__r.rstk__sootype_desc__c,CreatedDate,Picking_Loc_Formula_For_Templates__c,Sum_of_Qty_Ordered__c,rstk__sohdr_totalweight__c,Total_Tons_Formula__c,rstk__sohdr_otype__r.rstk__sootype_ordtype__c,rstk__soline_prod__r.rstk__soprod_prod__c,rstk__soline_prod__r.rstk__soprod_descr__c,rstk__soline_wocstordno__r.Batch_Order__r.Name,rstk__soline_prod__r.rstk__soprod_slsuom__r.rstk__syuom_uom__c,Order_Invoice__r.Sack_Trailer__c,Order_Invoice__r.Bulk_Trailer__c,Order_Invoice__r.Load__c,Order_Invoice__r.Stop__c,rstk__soline_line__c,rstk__soline_uom__r.rstk__syuom_uom__c,rstk__soline_price__c,rstk__soline_discpct__c,rstk__soline_ext__c,rstk__soline_taxexempt__c,rstk__sohdr_ordertotal__c,rstk__sohdr_totamt__c,Amount__c,Gross_Amount__c"
    templateId              = "aCT1Q0000004d64WAA,aHE6S000000TNLJWA4,aB24M000000002hSAA,aCT1Q000000CwIXWA0,aCTHp000000CwKsOAK,aBq1K0000004LYbSAM"
  }

  # Sensitive config vars - supplied via terraform.tfvars / TF_VAR_* env vars.
  sensitive_config_vars = {
    HEROKU_PASSWORD      = var.heroku_password
    HEROKU_USERNAME      = var.heroku_username
    MONGOLAB_URI         = var.mongolab_uri
    ORMONGO_DBNAME       = var.ormongo_dbname
    ORMONGO_PASSWORD     = var.ormongo_password
    ORMONGO_USERNAME     = var.ormongo_username
    SFORCE_CLIENT_KEY    = var.sforce_client_key
    SFORCE_CLIENT_SECRET = var.sforce_client_secret
    dburl                = var.dburl
  }
}

# -----------------------------------------------------------------------------
# Addon-injected config vars (NOT managed here)
# -----------------------------------------------------------------------------
# These are set automatically by the attached add-ons, so they are intentionally
# absent from the config above:
#   - ORMONGO_REGION        -> ormongo
#   - ORMONGO_RS_URL        -> ormongo
#   - ORMONGO_URL           -> ormongo
#   - PAPERTRAIL_API_TOKEN  -> papertrail (owned by this app)
