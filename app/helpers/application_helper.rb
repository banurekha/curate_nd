module ApplicationHelper
  # This is included to hopefully catch most of the sufia method calls that are
  # vestigal for the Sufia engine being included in the Gemfile but unmounted.
  def sufia
    self
  end

  def bootstrap_navigation_element(name, path)
    markup = ""

    if current_page? path
      markup = <<HTML
<li class="disabled">#{link_to name, '#', tabindex: :'-1'}</li>
HTML
    else
      markup = <<HTML
<li>#{link_to name, path}</li>
HTML
    end

    markup.html_safe()
  end

  def link_to_edit_permissions(curation_concern, solr_document = nil)
    markup = <<-HTML
      <a href="#{edit_polymorphic_path([:curation_concern, curation_concern])}" id="permission_#{curation_concern.to_param}">
        #{permission_badge_for(curation_concern, solr_document)}
      </a>
    HTML
    markup.html_safe
  end

  def permission_badge_for(curation_concern, solr_document = nil)
    solr_document ||= curation_concern.to_solr
    dom_label_class, link_title = extract_dom_label_class_and_link_title(solr_document)
    %(<span class="label #{dom_label_class}" title="#{link_title}">#{link_title}</span>).html_safe
  end

  def extract_dom_label_class_and_link_title(document)
    hash = document.stringify_keys
    dom_label_class, link_title = "label-important", "Private"
    if hash['read_access_group_t'].present?
      if hash['read_access_group_t'].include?('public')
        dom_label_class, link_title = 'label-success', 'Open Access'
      elsif has['read_access_group_t'].include?('registered')
        dom_label_class, link_title = "label-info", t('sufia.institution_name')
      end
    end
    return dom_label_class, link_title
  end
  private :extract_dom_label_class_and_link_title
end
