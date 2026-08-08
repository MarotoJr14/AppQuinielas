import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import type { ReactNode } from 'react';

type Tema = 'claro' | 'oscuro';

interface ThemeContextValue {
  tema: Tema;
  alternarTema: () => void;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

const STORAGE_KEY = 'quinielas_admin_theme';

function temaGuardado(): Tema {
  const guardado = localStorage.getItem(STORAGE_KEY);
  return guardado === 'oscuro' ? 'oscuro' : 'claro';
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [tema, setTema] = useState<Tema>(() => temaGuardado());

  useEffect(() => {
    document.documentElement.dataset.tema = tema;
    localStorage.setItem(STORAGE_KEY, tema);
  }, [tema]);

  const value = useMemo<ThemeContextValue>(
    () => ({
      tema,
      alternarTema: () => setTema((actual) => (actual === 'claro' ? 'oscuro' : 'claro')),
    }),
    [tema],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('useTheme debe usarse dentro de un ThemeProvider.');
  return ctx;
}
