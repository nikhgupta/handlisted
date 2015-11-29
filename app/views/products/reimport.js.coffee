$('#<%= present(@product).id %>').trigger("poll", '<%= @job_id %>')
