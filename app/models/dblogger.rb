module ActiveSupport
  class BufferedLogger
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

      data_specific_for_this_type_of_event = send('process_'+content_type+'_type_of_event', message)

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
      response_code = mes_arr[mes_arr.size - 3].to_i
      response_status = mes_arr[mes_arr.size - 2]
      request_url = mes_arr[mes_arr.size - 1][1..(mes_arr[mes_arr.size - 1].size-2)]

      {
        :processing_time => processing_time,
        :response_code => response_code,
        :response_status => response_status,
        :request_url => request_url
      }
    end

    def method_missing(method_name, *args)
      if method_name.to_s =~ /process_(.+)_type_of_event$/
        return {}
      end
    end
  end
end
