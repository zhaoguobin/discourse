import { propertyEqual } from "discourse/lib/computed";
import InputValidation from "discourse/models/input-validation";
import { emailValid } from "discourse/lib/utilities";
import computed from "ember-addons/ember-computed-decorators";

export default Ember.Controller.extend({
  taken: false,
  saving: false,
  error: false,
  success: false,
  newEmail: null,

  newEmailEmpty: Em.computed.empty("newEmail"),
  saveDisabled: Em.computed.or(
    "saving",
    "newEmailEmpty",
    "taken",
    "unchanged",
    "invalidEmail"
  ),
  unchanged: propertyEqual("newEmailLower", "currentUser.email"),

  reset() {
    this.setProperties({
      taken: false,
      saving: false,
      error: false,
      success: false,
      newEmail: null
    });
  },

  @computed("newEmail")
  newEmailLower(newEmail) {
    return newEmail.toLowerCase().trim();
  },

  @computed("saving")
  saveButtonText(saving) {
    if (saving) return I18n.t("saving");
    return I18n.t("user.change");
  },

  @computed("newEmail")
  invalidEmail(newEmail) {
    return !emailValid(newEmail);
  },

  @computed("invalidEmail")
  emailValidation(invalidEmail) {
    if (invalidEmail) {
      return InputValidation.create({
        failed: true,
        reason: I18n.t("user.email.invalid")
      });
    }
  },

  actions: {
    changeEmail() {
      const self = this;
      this.set("saving", true);

      return this.get("model")
        .changeEmail(this.get("newEmail"))
        .then(
          () => self.set("success", true),
          e => {
            self.setProperties({ error: true, saving: false });
            if (
              e.jqXHR.responseJSON &&
              e.jqXHR.responseJSON.errors &&
              e.jqXHR.responseJSON.errors[0]
            ) {
              self.set("errorMessage", e.jqXHR.responseJSON.errors[0]);
            } else {
              self.set("errorMessage", I18n.t("user.change_email.error"));
            }
          }
        );
    }
  }
});
