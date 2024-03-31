clear all; close all; clc;
syms s t real
% Tito Ricardo Clemente
% Ingeniería Electronica
% Sistema de Control II - 2023
% 1. Actividad Práctica Nº1 Representación de sistemas y control PID 
% ===================================================================
% Circuito RLC - CASO 3
% Ve: tensión de entrada [Volts]
% L: inductancia [Henrios]
% C: capacidad [Faradios]
% R: resistencia [Ohms]
% Vr: tensión de salida (en la resistencia) [Volts]
% i: corriente

% Sistema Original por Datos
% --------------------------
% guardo los datos del excel en una variable 

tiempo_d = xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','A:A');
corriente_L=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','B:B');
tension_C=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','C:C');
escalon_d=xlsread('Curvas_Medidas_RLC_2024.xls','Hoja1','D:D');
figure(1);
plot(tiempo_d,corriente_L,'red'); hold on
title('Curvas Datos Corriente en el inductor - Original');
xlabel('Tiempo [segundos]');
ylabel('Corriente [Amper]');

% Defino un nuevo tiempo para poder relacionarlo con las correspondientes
% tensiones y corrientes.
% ya que solo necesito los valores correspondientes a la entrada escalon de
% 12 V.
% tomo solamente los valores mayores a 0 Voltios
% incio 10 ms hasta los 49,9 ms (101,500)
% creo una funcion que solo me de los valores que necesito, osea el primero
% ciclo, porque es el que posee condiciones iniciales nulas:

% Para la Corriente del inductor
[tiempo_S,corriente_S,entrada]=CurvaCondicionesInicialesNulas(tiempo_d,corriente_L,escalon_d,length(tiempo_d));


% Aplico Metodo de Chen
% ---------------------
%Elijo 3 puntos equidistantes (en tiempo) en la grafica de la respuesta al
%escalon del voltaje del capacitor (Tercera columna de excel):
% identifico tres puntos
t_inicial=0.3e-3;
[~,punto]=min(abs(t_inicial-tiempo_S));
t_t1=tiempo_S(punto); y1_v = corriente_S(punto);
[~,punto]=min(abs((t_inicial*2)-tiempo_S)); 
t_t2=tiempo_S(punto); y2_v = corriente_S(punto);
[~,punto]=min(abs((t_inicial*3)-tiempo_S)); 
t_t3=tiempo_S(punto); y3_v = corriente_S(punto);

%Ademas, tambien debo elegir un cuarto punto para normalizar la ganancia:
[~,punto]=min(abs(tiempo_S(end)-tiempo_S));
t_t4 = tiempo_S(punto);        y4_v = corriente_S(punto);

figure(2)
plot(tiempo_S,corriente_S,'blue');hold on
plot([t_t1 t_t2 t_t3 t_t4],[y1_v y2_v y3_v y4_v],'*');hold on;
title('Curvas Datos Corriente - Puntos para Chen *');
xlabel('Tiempo [segundos]');
ylabel('Corriente [Amper]');

% Siendo un sistema de segundo Orden, para identificarlo, debo de
% normalizar la entrada del sistema y ademas la salida correspondiente a la
% tension del Capacitor.

% Defino el Entrada Escalón del Sistema
amplitud_escalon=entrada(end)/12; % normalizo el arreglo para que sea una entrada escalón

% Conciderando la salida como el último valor de la Tensión en C:
% tomo el ultimo valor del escalon unitario:

K=y4_v/amplitud_escalon;
k1=(1/amplitud_escalon)*y1_v/K-1;
k2=(1/amplitud_escalon)*y2_v/K-1;
k3=(1/amplitud_escalon)*y3_v/K-1;

% Ecuaciones desarrolladas bajo el supesto T1<T2 y alfa1<alfa2
be=4*k1^3*k3-3*k1^2*k2^2-4*k2^3+k3^2+6*k1*k2*k3; 
alfa1=(k1*k2+k3-sqrt(be))/(2*(k1^2+k2)); 
alfa2=(k1*k2+k3+sqrt(be))/(2*(k1^2+k2)); 
beta=(k1+alfa2)/(alfa1-alfa2);

% Remplazo en los valores de las constantes de tiempo T1, T2 y T3:
% si se toma los valor completos se resta el tiempo muerto o sea 10 ms
% T_1=-(t_t1-10e-3)/log(alfa1); 
T_1=-t_t1/log(alfa1); 
% T_1=-(t_t1-10e-3)/log(alfa2); 
T_2=-t_t1/log(alfa2); 
T_3=beta*(T_1-T_2)+T_1; 

% Sistema Aproximado Final:
G_s=tf(K*[T_3 1],conv([T_2 1],[T_1 1]))


[G_sS , t_S] = lsim(G_s , escalon_d/12 , tiempo_d);

% Sistema Aproximado.
figure(1)
plot(t_S, G_sS, 'k') ; title('Función G_s obtenida por CHEN vs I_L original');
title('Curvas Medidas RLC / Curva Aproximada')
xlabel('Tiempo [segundos]')
ylabel('Amplitud Corriente en el Inductor')

G_s=zpk(G_s)

L=1/(G_s.K)
C=1/(G_s.P{1,1}(1,1))*(G_s.P{1,1}(2,1))*L
R=-L*(G_s.P{1,1}(1,1)+G_s.P{1,1}(2,1))

function [X,Y,Z]=CurvaCondicionesInicialesNulas(t,iL,Ve,iteracion)
    t_aux=[];
    ve_aux=[];
    il_aux=[];
    j=1;
    for i=1:1:iteracion
      if Ve(i)~=0
          if Ve(i)==12
              if j==1
              t_inic=t(i);% valor inicial
              end
              t_aux(j)=t(i)-t_inic;
              ve_aux(j)=Ve(i);
              il_aux(j)=iL(i);
              j=j+1;
          else
              break
          end
      end
    end
X=t_aux;
Y=il_aux;
Z=ve_aux;
end

