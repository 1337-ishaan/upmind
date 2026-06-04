import React from 'react';
import renderer from 'react-test-renderer';
import OnboardingWelcome from '../app/(onboarding)/index';

describe('Onboarding welcome', () => {
  it('renders the headline and CTA', () => {
    const tree = renderer.create(<OnboardingWelcome />).toJSON();
    const json = JSON.stringify(tree);
    expect(json).toMatch(/UPMIND/);
    expect(json).toMatch(/Begin/);
    expect(json).toMatch(/Sign in/);
  });
});
