DB[:users].import [:name], Array.new(1000) { [['Alex'], ['Roman'], ['Jake'], ['Kyle'], ['Charlie'], ['Damian']].sample } if DB[:users].empty?
