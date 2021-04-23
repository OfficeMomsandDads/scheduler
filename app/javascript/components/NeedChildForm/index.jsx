import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

const capitalize = (s) => {
  if (typeof s !== 'string') return ''
  return s.charAt(0).toUpperCase() + s.slice(1)
}

const AgeInput = props => {
  return (
    <div className="field">
      <label>Age
        <input type="number" defaultValue={props.child.age} name={`need[children_attributes][${props.index}][age]`} />
      </label>
    </div>
  )
}

const SexInput = props => {
  return (
    <div className="field">
      <label>Sex
        <select name={`need[children_attributes][${props.index}][sex]`} defaultValue={props.child.sex}>
            {props.childSexes.map((sex, index) =>
              <option key={index} value={sex}>{ capitalize(sex) }</option>
            )}
        </select>
      </label>
    </div>
  )
}

const NotesInput = props => {
  return (
    <div className="field">
      <label>Notes
        <textarea rows="5" name={`need[children_attributes][${props.index}][notes]`} defaultValue={props.child.notes} />
      </label>
    </div>
  )
}

const IdInput = props => {
  return props.child.id ?
    <input type="hidden" defaultValue={props.child.id} name={`need[children_attributes][${props.index}][id]`} />
    : null
}

const DestroyInput = props => {
  return <input type="hidden" defaultValue={props.child._destroy} name={`need[children_attributes][${props.index}][_destroy]`} />
}

class NeedChildForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { children: props.children };
  }

  destroyChild = index => {
    const child = Object.assign({}, this.state.children[index], {
      _destroy: true
    })
    this.setState({ children: [...this.state.children.filter((e, i) => i != index), child] })
  }

  addChild = index => {
    this.setState({ children: [...this.state.children, {}] })
  }

  childPosition = child => {
    const actualChildren = this.state.children.filter( e => !e._destroy )
    return actualChildren.indexOf(child) + 1
  }

  render() {
    return (
      <div>
        {this.state.children.map((child, index) =>
          <div key={index} className="card" style={{width: '100%', display: child._destroy ? 'none' : 'block'}}>
            <div className="card-divider">
                <h4>Child {this.childPosition(child)}</h4>
                <button className="close-button" onClick={this.destroyChild.bind(this, index)} aria-label="Close alert" type="button">
                  <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div className="card-section">
              <AgeInput {...{child, index}} />
              <SexInput childSexes={this.props.childSexes} {...{child, index}} />
              <NotesInput {...{child, index}} />
              <IdInput {...{child, index}} />
              <DestroyInput {...{child, index}} />
            </div>
          </div>
        )}
        <button type="button" onClick={this.addChild} className="primary button small">+ Add Child</button>
      </div>
    )
  }
}

export default NeedChildForm