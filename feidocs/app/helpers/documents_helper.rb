module DocumentsHelper

def document_professor(document_id)
  @professors = Professor.where.not(collaborators: Collaborator.find_by(document_id: document_id))
end

def show_doc(path)
  require 'docx'
  doc = Docx::Document.open(path)
  doc.paragraphs.each do |p|
    puts p.to_html
  end
end

end