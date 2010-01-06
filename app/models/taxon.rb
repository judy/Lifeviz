# == Schema Information
#
# Table name: taxa
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  rank        :integer
#  lineage_ids :string(255)
#

class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  def paginated_sorted_species(page)
    Taxon.paginate_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC", :page => page)
  end
  
  def organism
    Organism.find(:first, :conditions => ["taxon_id = ?", id])
  end
  
  def parents
    lineage_ids.split(/,/).collect { |ancestor_id| Taxon.find(ancestor_id) }
  end
  
  # Rebuild lineage_ids for this taxon.
  def rebuild_lineage_ids
    update_attributes(:lineage_ids => (parent.lineage_ids + "," + parent_id.to_s))
  end
  
  # This method rebuilds lineage_ids for the entire taxonomy.
  def self.rebuild_lineages!
    Taxon.find(1).rebuild_lineage_branch(nil) # Run rebuild_lineage on root node.
  end
  
  # This is a recursive method to rebuild a tree of lineage_ids.
  def rebuild_lineage_branch(parent_id, parent_lineage_ids="")
    lineage_ids = if parent_id.nil?  # Root node
                    ""
                  elsif parent_lineage_ids == "" || parent_id == 1 # Child of root node
                    "1"
                  else
                    parent_lineage_ids + "," + parent_id.to_s
                  end     
    
    update_attributes(:lineage_ids => lineage_ids)
    
    unless leaf?
      children.each {|child| child.rebuild_lineage_branch(id, lineage_ids)}
    end
  end
  
end
