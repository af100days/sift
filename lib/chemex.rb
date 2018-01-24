require "chemex/filter"
require "chemex/filter_validator"
require "chemex/filtrator"
require "chemex/sort"
require "chemex/subset_comparator"
require "chemex/type_validator"
require "chemex/parameter"
require "chemex/scope_handler"
require "chemex/where_handler"
require "chemex/validators/valid_int_validator"

module Chemex
  extend ActiveSupport::Concern

  def filtrate(collection)
    Filtrator.filter(collection, params, filters)
  end

  def filter_params
    params.fetch(:filters, {})
  end

  def sort_params
    params.fetch(:sort, "").split(",") if filters.any? { |filter| filter.is_a?(Sort) }
  end

  def filters_valid?
    filter_validator.valid?
  end

  def filter_errors
    filter_validator.errors.messages
  end

  private

  def filter_validator
    @_filter_validator ||= FilterValidator.build(
      filters: filters,
      sort_fields: self.class.sort_fields,
      filter_params: filter_params,
      sort_params: sort_params,
    )
  end

  def filters
    self.class.filters
  end

  def sorts_exist?
    filters.any? { |filter| filter.is_a?(Sort) }
  end

  class_methods do
    def filter_on(parameter, type:, internal_name: parameter, default: nil, validate: nil, scope_params: [])
      filters << Filter.new(parameter, type, internal_name, default, validate, scope_params)
    end

    def filters
      @_filters ||= []
    end

    # TODO: this is only used in tests, can I kill it?
    def reset_filters
      @_filters = []
    end

    def sort_fields
      @_sort_fields ||= []
    end

    def sort_on(parameter, type:, internal_name: parameter, scope_params: [])
      filters << Sort.new(parameter, type, internal_name, scope_params)
      sort_fields << parameter.to_s
      sort_fields << "-#{parameter}"
    end
  end
end