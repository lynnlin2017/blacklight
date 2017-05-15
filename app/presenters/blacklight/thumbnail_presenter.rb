# frozen_string_literal: true

module Blacklight
  class ThumbnailPresenter
    attr_reader :document_presenter, :view_config

    # @param [IndexPresenter] document_presenter for linking and generating urls
    # @param [Blacklight::Configuration::ViewConfig] view_config
    def initialize(document_presenter, view_config)
      @document_presenter = document_presenter
      @view_config = view_config
    end

    ##
    # Does the document have a thumbnail to render?
    #
    # @return [Boolean]
    def exists?
      thumbnail_method.present? || thumbnail_field && @document_presenter.document.has?(thumbnail_field)
    end

    ##
    # Render the thumbnail, if available, for a document and
    # link it to the document record.
    #
    # @param [Hash] image_options to pass to the image tag
    # @param [Hash] url_options to pass to IndexPresenter#link_to_document
    # @return [String]
    # rubocop:disable Lint/AssignmentInCondition
    def thumbnail_tag image_options = {}, url_options = {}
      return unless value = thumbnail_value(image_options)
      if url_options == false || url_options[:suppress_link]
        value
      else
        document_presenter.link_to_document value, url_options
      end
    end
    # rubocop:enable Lint/AssignmentInCondition

    private

    delegate :thumbnail_field, :thumbnail_method, to: :view_config

    # @param [Hash] image_options to pass to the image tag
    def thumbnail_value(image_options)
      if thumbnail_method
        document_presenter.view_context.send(thumbnail_method, document_presenter.document, image_options)
      elsif thumbnail_field
        url = document_presenter.document.first(thumbnail_field)
        document_presenter.view_context.image_tag url, image_options if url.present?
      end
    end
  end
end
