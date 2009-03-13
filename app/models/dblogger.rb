module ActiveSupport
  class BufferedLogger
    @@PREDEFINED_EVENT_TYPES = %w(rendering parameters session attempting rendered cookie failed redirected filter migrating processing completed)

    def add(severity, message = nil, progname = nil, &block)
      return if @level > severity
      message = (message || (block && block.call) || progname).to_s

      level = sev_to_level severity

      content_type = message.split[0].delete(":").downcase

      common_item_data = {:environment => RAILS_ENV,
        :level => level,
        :message => message,
        :block_text => (block && block.call).to_s,
        :content_type => content_type,
        :request_id => $$
      }

      data_specific_for_this_type_of_event = @@PREDEFINED_EVENT_TYPES.include?(content_type) ? send('process_'+content_type+'_type_of_event', message) : {}

      LoggedEvent.create! common_item_data.merge(data_specific_for_this_type_of_event)
    end

    def sev_to_level severity
      LoggedEvent.types_of_events[severity] || "U"
    end

    def process_processing_type_of_event message
      mes_arr = message.split

      controller = mes_arr[1].split("#")[0]
      action = mes_arr[1].split("#")[1]
      ip = mes_arr[3]
      request_type = mes_arr[7][1..(mes_arr[7].size-2)]

      {
        :controller => controller,
        :action => action,
        :ip => ip,
        :request_type => request_type
      }
    end

    def process_completed_type_of_event message
      mes_arr = message.split

      processing_time = mes_arr[2].delete("ms").to_i
      response_code = mes_arr[8].to_i
      response_status = mes_arr[9]
      request_url = mes_arr[10][1..(mes_arr[10].size-2)]

      {
        :processing_time => processing_time,
        :response_code => response_code,
        :response_status => response_status,
        :request_url => request_url
      }
    end

    (@@PREDEFINED_EVENT_TYPES - ['processing', 'completed']).each do |name|
      class_eval <<-EOT, __FILE__, __LINE__
        def process_#{name}_type_of_event message
          {}
        end
      EOT
    end
  end
end