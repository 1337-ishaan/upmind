import { create } from './_zustandShim';

type Survey = {
  reason: string | null;
  struggle: string | null;
  priority: string | null;
  priming: string | null;
  commitment: string | null;
  age: string | null;
  occupation: string | null;
};

type State = {
  step: number; // current onboarding step index
  setStep: (n: number) => void;
  survey: Survey;
  setSurvey: (patch: Partial<Survey>) => void;
  briefingScore: number | null;
  setBriefingScore: (s: number) => void;
  reset: () => void;
};

const initialSurvey: Survey = {
  reason: null,
  struggle: null,
  priority: null,
  priming: null,
  commitment: null,
  age: null,
  occupation: null,
};

export const useOnboarding = create<State>((set) => ({
  step: 0,
  setStep: (n) => set({ step: n }),
  survey: initialSurvey,
  setSurvey: (patch) => set((s) => ({ survey: { ...s.survey, ...patch } })),
  briefingScore: null,
  setBriefingScore: (s) => set({ briefingScore: s }),
  reset: () => set({ step: 0, survey: initialSurvey, briefingScore: null }),
}));
