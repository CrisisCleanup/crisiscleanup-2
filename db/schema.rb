# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150703181119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "legacy_contacts", force: :cascade do |t|
    t.string  "email",                  null: false
    t.string  "first_name",             null: false
    t.string  "last_name",              null: false
    t.integer "legacy_organization_id", null: false
    t.boolean "is_primary"
    t.string  "phone",                  null: false
  end

  create_table "legacy_events", force: :cascade do |t|
    t.string   "case_label",                     null: false
    t.string   "counties",          default: [],              array: true
    t.string   "name",                           null: false
    t.string   "short_name",                     null: false
    t.date     "created_date",                   null: false
    t.date     "start_date",                     null: false
    t.date     "end_date",                       null: false
    t.integer  "num_sites"
    t.string   "reminder_contents"
    t.integer  "reminder_days"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "legacy_organization_events", force: :cascade do |t|
    t.integer "legacy_organization_id", null: false
    t.integer "legacy_event_id",        null: false
  end

  create_table "legacy_organizations", force: :cascade do |t|
    t.date     "activate_by",                                 null: false
    t.date     "activated_at",                                null: false
    t.string   "activation_code",                             null: false
    t.string   "address",                                     null: false
    t.string   "admin_notes"
    t.string   "city",                                        null: false
    t.boolean  "deprecated",                  default: false
    t.boolean  "does_only_coordination",      default: false
    t.boolean  "does_only_sit_aware",         default: false
    t.boolean  "does_recovery",               default: false
    t.boolean  "does_something_else",         default: false
    t.string   "email",                                       null: false
    t.string   "facebook"
    t.boolean  "is_active",                                   null: false
    t.boolean  "is_admin",                    default: false
    t.float    "latitude",                                    null: false
    t.float    "longitude",                                   null: false
    t.string   "name",                                        null: false
    t.boolean  "not_an_org",                  default: false
    t.boolean  "only_session_authentication", default: false
    t.boolean  "org_verified",                default: false
    t.string   "password",                                    null: false
    t.string   "permissions",                                 null: false
    t.string   "phone",                                       null: false
    t.boolean  "physical_presence",                           null: false
    t.boolean  "publish",                                     null: false
    t.boolean  "reputable",                                   null: false
    t.string   "state",                                       null: false
    t.string   "terms_privacy"
    t.datetime "timestamp_login"
    t.datetime "timestamp_signup",                            null: false
    t.string   "twitter"
    t.string   "url"
    t.text     "voad_referral"
    t.string   "work_area",                                   null: false
    t.string   "zip_code",                                    null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "legacy_sites", force: :cascade do |t|
    t.string   "address",           null: false
    t.float    "blurred_latitude",  null: false
    t.float    "blurred_longitude", null: false
    t.string   "case_number",       null: false
    t.string   "city",              null: false
    t.integer  "claimed_by"
    t.integer  "legacy_event_id",   null: false
    t.float    "latitude",          null: false
    t.float    "longitude",         null: false
    t.string   "name",              null: false
    t.string   "phone",             null: false
    t.integer  "reported_by",       null: false
    t.date     "requested_at",      null: false
    t.string   "state",             null: false
    t.string   "status",            null: false
    t.string   "work_type",         null: false
    t.hstore   "data"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
