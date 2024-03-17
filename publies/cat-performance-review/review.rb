require "erb"

RATE_UNSATISFACTORY = "Bellow exp."
RATE_MEETS = "Meets exp."
RATE_EXCEEDS = "Exceeds exp."

def standard_radio(title, group)
    %Q(
        <legend class="required">#{title}</legend>
        #{radio(group, RATE_UNSATISFACTORY)}
        #{radio(group, RATE_MEETS)}
        #{radio(group, RATE_EXCEEDS)}
    )
end

def radio(group, label)
    %Q(
        <input type="radio" name="#{group}" />
        <label>#{label}</label>
    )
end

def text(name, c = 'required')
    %Q(
    <li class="textField">
    <label class="#{c}">#{name}</label>
    <input type="text" />
    </li>
  )
end

def objective(id)
    %Q(
    <li class="objectiveField">
    <label>#{id}</label>
    <input type="text" />
    </li>
    <li class="objectiveRadio">
    #{radio("objetive_#{id}", RATE_UNSATISFACTORY)}
    #{radio("objetive_#{id}", RATE_MEETS)}
    #{radio("objetive_#{id}", RATE_EXCEEDS)}
</li>
  )
end

rhtml = ERB.new(IO.read('review.html.erb'))
File.write("review.html", rhtml.result(binding))
