import React from 'react';
import renderer from 'react-test-renderer';
import WelcomeScreen from '../src/screens/WelcomeScreen';

describe('WelcomeScreen', () => {
  it('renders the headline and CTA', () => {
    const tree = renderer.create(<WelcomeScreen />).toJSON();
    const json = JSON.stringify(tree);
    expect(json).toMatch(/Congratulations/);
    expect(json).toMatch(/Begin/);
    expect(json).toMatch(/Sign in/);
  });

  it('matches the snapshot', () => {
    const tree = renderer.create(<WelcomeScreen />).toJSON();
    expect(tree).toMatchSnapshot();
  });
});
