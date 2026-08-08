import type { InputHTMLAttributes, ReactNode, SelectHTMLAttributes } from 'react';

interface CampoWrapperProps {
  etiqueta?: string;
  ayuda?: string;
  error?: string;
  children: ReactNode;
}

export function CampoWrapper({ etiqueta, ayuda, error, children }: CampoWrapperProps) {
  return (
    <div className="campo">
      {etiqueta ? <label className="campo__etiqueta">{etiqueta}</label> : null}
      {children}
      {error ? <span className="campo__error">{error}</span> : ayuda ? <span className="campo__ayuda">{ayuda}</span> : null}
    </div>
  );
}

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  etiqueta?: string;
  ayuda?: string;
  error?: string;
}

export function Input({ etiqueta, ayuda, error, className, ...rest }: InputProps) {
  return (
    <CampoWrapper etiqueta={etiqueta} ayuda={ayuda} error={error}>
      <input className={`input ${className ?? ''}`} {...rest} />
    </CampoWrapper>
  );
}

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  etiqueta?: string;
  ayuda?: string;
  error?: string;
  children: ReactNode;
}

export function Select({ etiqueta, ayuda, error, className, children, ...rest }: SelectProps) {
  return (
    <CampoWrapper etiqueta={etiqueta} ayuda={ayuda} error={error}>
      <select className={`select ${className ?? ''}`} {...rest}>
        {children}
      </select>
    </CampoWrapper>
  );
}
