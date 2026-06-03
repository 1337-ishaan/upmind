import { useOnboarding } from '../src/state';

describe('onboarding store', () => {
  beforeEach(() => useOnboarding.getState().reset());

  it('starts at step 0 with empty survey', () => {
    const s = useOnboarding.getState();
    expect(s.step).toBe(0);
    expect(s.survey).toEqual({
      reason: null,
      struggle: null,
      priority: null,
      priming: null,
      commitment: null,
      age: null,
      occupation: null,
    });
    expect(s.briefingScore).toBeNull();
  });

  it('setStep moves forward and back', () => {
    useOnboarding.getState().setStep(3);
    expect(useOnboarding.getState().step).toBe(3);
    useOnboarding.getState().setStep(1);
    expect(useOnboarding.getState().step).toBe(1);
  });

  it('setSurvey merges a partial patch', () => {
    useOnboarding.getState().setSurvey({ reason: 'focus', struggle: 'overwhelm' });
    const s = useOnboarding.getState().survey;
    expect(s.reason).toBe('focus');
    expect(s.struggle).toBe('overwhelm');
    expect(s.priority).toBeNull();
  });

  it('setBriefingScore persists and reset clears it', () => {
    useOnboarding.getState().setBriefingScore(7);
    expect(useOnboarding.getState().briefingScore).toBe(7);
    useOnboarding.getState().reset();
    expect(useOnboarding.getState().briefingScore).toBeNull();
  });
});
