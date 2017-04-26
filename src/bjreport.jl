type VarCstrReport
  cstrs_report
  vars_report
end
VarCstrReport() = VarCstrReport(nothing, nothing)

function report_cstrs_and_vars!(m::JuMP.Model)
  nbrows = length(m.linconstr)
  nbcols = length(m.colNames)
  m.ext[:varcstr_report].cstrs_report = Array{Tuple{Symbol, Union{Tuple,Void}}}(nbrows)
  m.ext[:varcstr_report].vars_report = Array{Tuple{Symbol, Union{Tuple,Void}}}(nbcols)
  report_names_and_indexes!(m.ext[:varcstr_report].cstrs_report, m.conDict)
  report_names_and_indexes!(m.ext[:varcstr_report].vars_report, m.varDict)
  check_for_anonymous(m.ext[:varcstr_report].cstrs_report)
  check_for_anonymous(m.ext[:varcstr_report].vars_report)
end

function check_for_anonymous(report)
  for i in 1:length(report)
    if !isassigned(report, i)
      info = "Make sure that all variables and constraints have a name."
      errmsg = "BlockDecomposition does not support anonymous variables or constraints."
      bjerror(info, errmsg)
    end
  end
end

function report_names_and_indexes!(report::Array{Tuple{Symbol, Union{Tuple,Void}}}, dict)
  for collection in dict
    name = string(collection.first)
    # Is it a JuMP Container ? or an array ?
    isjumpcontnr = isa_jumpcontnr(collection.second)
    isarray = isa_array(collection.second)
    (isjumpcontnr || isarray) && add_names_and_indexes!(report, collection)
    # Is it a single constraint or a single variable ?
    isjumpcstr = isa_jumpcstr(collection.second)
    isjumpvar = isa_jumpvar(collection.second)
    (isjumpcstr || isjumpvar) && add_name_and_index!(report, collection)
    # error
    (!isjumpcontnr && !isarray && !isjumpcstr && !isjumpvar) && bjerror("Unsupported type : collection name = $name and type = $(typeof(collection.second))") #TODO
  end
end

function getpos(vc) :: Integer
  if isa_jumpcstr(vc)
    return vc.idx
  end
  if isa_jumpvar(vc)
    return vc.col
  end
  bjerror("Error!")
end

function add_names_and_indexes!(report, collection)
  name = collection.first
  for index in keys(collection.second)
      pos = getpos(collection.second[index...])
      report[pos] = (name, index)
  end
end

function add_name_and_index!(report, singleton)
  name = singleton.first
  pos = getpos(singleton.second)
  report[pos] = (name, nothing)
end
