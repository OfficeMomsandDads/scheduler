import React from "react"
import PropTypes from "prop-types"
import Moment from 'moment'
import { extendMoment } from 'moment-range'
import DayPickerInput from 'react-day-picker/DayPickerInput';
import BlockoutFormContext from './blockout-form-context'

const moment = extendMoment(Moment)

class DateTimePicker extends React.Component {
  timeOptions = _ => {
    const begin = moment().hour(6).minute(30).second(0)
    const end   = moment().hour(23).minute(30).second(0)
    const range = moment.range(begin, end)
    const times = Array.from(range.by('minutes', {step: 30}))
    const options = times.map(t => ({value: t.format('HH:mm'), text: t.format('h:mm a')}))
    options.unshift({value: moment().startOf('day').format('HH:mm'), text: 'Start of Day'})
    options.push({value: moment().endOf('day').format('HH:mm'), text: 'End of Day'})
    return options
  }

  state ={
    allDay: true,
    timeOptions: this.timeOptions()
  }

  toggleAllDay = setFormInputs => {
    if (this.state.allDay) {
      this.setState(state => ({ allDay: false }))
    } else {
      this.setState(state => ({ allDay: true }))
      setFormInputs({fromTime: '00:00', toTime: '23:59'})
    }
  }

  renderTimeSelectOptions = _ => {
    return this.state.timeOptions.map(({value, text}, index) => {
      return <option value={value} key={index}>{text}</option>
    })
  }

  renderTimeSelect = (input, value, setFormInputs) => {
    if (!this.state.allDay) {
      return (
        <select value={value} onChange={event => setFormInputs({[input]: event.target.value})}>
          {this.renderTimeSelectOptions(input)}
        </select>
      )
    }
  }

  render () {
    const { toggleAllDay, renderTimeSelect, state: { allDay } } = this
    return (
      <BlockoutFormContext.Consumer>
        {({ inputs: {fromDate, toDate, fromTime, toTime}, setFormInputs }) => (
          <div className="grid-x grid-margin-x blockout-date-time-picker">
            <div className="cell small-2">
              <label>
                All Day
                <input type='checkbox' defaultChecked={allDay} onChange={ toggleAllDay.bind(this, setFormInputs) } />
              </label>
            </div>
            <div className="cell small-5">
              <label htmlFor=''>Start Date</label>
              <DayPickerInput
                inputProps={{ type: 'text' }}
                value={fromDate}
                formatDate={date => moment(date).format('ll')}
                onDayChange={day => setFormInputs({ fromDate: day })}
                dayPickerProps={{
                  selectedDays: [fromDate, { fromDate, toDate }],
                  disabledDays: { after: toDate }
                }}
              />
              {renderTimeSelect('fromTime', fromTime, setFormInputs)}
            </div>
            <div className="cell small-5">
              <label htmlFor=''>End Date</label>
              <DayPickerInput
                inputProps={{ type: 'text' }}
                value={toDate}
                formatDate={date => moment(date).format('ll')}
                onDayChange={day => setFormInputs({ toDate: day })}
                dayPickerProps={{
                  selectedDays: [fromDate, { fromDate, toDate }],
                  disabledDays: { before: fromDate }
                }}
              />
              {renderTimeSelect('toTime', toTime, setFormInputs)}
            </div>
          </div>
        )}
      </BlockoutFormContext.Consumer>
    )
  }
}

DateTimePicker.propTypes = {
  data: PropTypes.object
}

export default DateTimePicker
