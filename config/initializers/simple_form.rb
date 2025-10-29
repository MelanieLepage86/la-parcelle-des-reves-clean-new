# frozen_string_literal: true

SimpleForm.setup do |config|
  # ========== Options générales ==========
  config.button_class = 'btn btn-primary'
  config.boolean_label_class = 'form-check-label'
  config.error_notification_class = 'alert alert-danger'
  config.error_method = :to_sentence

  # Affichage du label + astérisque si requis
  config.label_text = lambda { |label, required, _| "#{label} #{required}" }

  # Validation visuelle (champs valides/invalides)
  config.input_field_error_class = 'is-invalid'
  config.input_field_valid_class = 'is-valid'

  # Ne pas utiliser la validation HTML5 native
  config.browser_validations = false

  # ========== Wrappers Bootstrap 5 ==========

  ## Formulaire vertical (le plus courant)
  config.wrappers :vertical_form, class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  ## Case à cocher / boolean
  config.wrappers :vertical_boolean, tag: 'fieldset', class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: 'form-check' do |bb|
      bb.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      bb.use :label, class: 'form-check-label'
      bb.use :full_error, wrap_with: { class: 'invalid-feedback' }
      bb.use :hint, wrap_with: { class: 'form-text' }
    end
  end

  ## Select
  config.wrappers :vertical_select, class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-select', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  ## Upload de fichier
  config.wrappers :vertical_file, class: 'mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  ## Range input
  config.wrappers :vertical_range, class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.optional :step
    b.use :label, class: 'form-label'
    b.use :input, class: 'form-range', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  ## Switch (toggle Bootstrap)
  config.wrappers :custom_boolean_switch, class: 'mb-3' do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, tag: 'div', class: 'form-check form-switch' do |bb|
      bb.use :input, class: 'form-check-input', error_class: 'is-invalid', valid_class: 'is-valid'
      bb.use :label, class: 'form-check-label'
      bb.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      bb.use :hint, wrap_with: { class: 'form-text' }
    end
  end

  ## Floating labels (style moderne Bootstrap)
  config.wrappers :floating_labels_form, class: 'form-floating mb-3' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
    b.use :label
    b.use :full_error, wrap_with: { class: 'invalid-feedback' }
    b.use :hint, wrap_with: { class: 'form-text' }
  end

  # ========== Wrapper par défaut ==========
  config.default_wrapper = :vertical_form

  # ========== Mapping selon type de champ ==========
  config.wrapper_mappings = {
    boolean:       :vertical_boolean,
    check_boxes:   :vertical_boolean,
    radio_buttons: :vertical_boolean,
    file:          :vertical_file,
    range:         :vertical_range,
    select:        :vertical_select
  }
end
