%   CLASS Tropo_Sinex_Compare
% =========================================================================
%
% DESCRIPTION
%   Class to compare tropo result whìith external solutions
% EXAMPLE
%   tsc = Tropo_Sinex_Compare();
%


%--- * --. --- --. .--. ... * ---------------------------------------------
%               ___ ___ ___
%     __ _ ___ / __| _ | __|
%    / _` / _ \ (_ |  _|__ \
%    \__, \___/\___|_| |___/
%    |___/                    v 1.0 beta 1
%
%--------------------------------------------------------------------------
%  Copyright (C) 2009-2018 Mirko Reguzzoni, Eugenio Realini
%  Written by: Giulio Tagliaferro
%  Contributors:     ...
%  A list of all the historical goGPS contributors is in CREDITS.nfo
%--------------------------------------------------------------------------
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%--------------------------------------------------------------------------
% 01100111 01101111 01000111 01010000 01010011
%--------------------------------------------------------------------------
classdef Tropo_Sinex_Compare < handle
    
    properties
        results
        log
    end
    
    methods
        function this = Tropo_Sinex_Compare()
            this.results = struct();
            this.log = Logger.getInstance();
        end
        function addTropoSinexFile(this, filename, result_n)
            % add sinex file any previous data will be overwritten
            %
            % SYNTAX
            %     this.addTropoSinexFile(filename, <result_n>)
            
            if nargin < 3
                result_n = 2;
            end
            if ~isfield(this.results, ['r' num2str(result_n)])
                this.results.(['r' num2str(result_n)]) = struct();
            end
            [results] = this.parseMultiStationTropoSinex(filename);
            stas = fieldnames(results);
            if isempty(stas)
                this.log.addWarning('No result present in file')
            else
                for s = 1:length(stas)
                    data = results.(stas{s});
                    if isfield(this.results.(['r' num2str(result_n)]), stas{s})
                        
                        [this.results.(['r' num2str(result_n)]).(stas{s}).time, idx1, idx2] = this.results.(['r' num2str(result_n)]).(stas{s}).time.injectBatch(data.time);
                        this.results.(['r' num2str(result_n)]).(stas{s}).ztd     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).ztd, data.TROTOT , idx1, idx2);
                        this.results.(['r' num2str(result_n)]).(stas{s}).tgn     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).tgn, data.TGNTOT, idx1, idx2);
                        this.results.(['r' num2str(result_n)]).(stas{s}).tge     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).tge, data.TGETOT, idx1, idx2);
                        idx_time_coord = this.results.(['r' num2str(result_n)]).(stas{s}).coord_time == data.time.getCentralTime;
                        if sum(idx_time_coord) == 0
                            this.results.(['r' num2str(result_n)]).(stas{s}).xyz(end+1,:)     = data.xyz;
                            this.results.(['r' num2str(result_n)]).(stas{s}).coord_time.append(data.time.getCentralTime);
                        else
                            this.results.(['r' num2str(result_n)]).(stas{s}).xyz(idx_time_coord,:)     = data.xyz;
                        end
                    else
                        this.results.(['r' num2str(result_n)]).(stas{s}) = struct();
                        this.results.(['r' num2str(result_n)]).(stas{s}).time = data.time.getCopy();
                        this.results.(['r' num2str(result_n)]).(stas{s}).ztd = data.TROTOT;
                        this.results.(['r' num2str(result_n)]).(stas{s}).tgn = data.TGNTOT;
                        this.results.(['r' num2str(result_n)]).(stas{s}).tge = data.TGETOT;
                        this.results.(['r' num2str(result_n)]).(stas{s}).coord_time = data.time.getCentralTime();
                        this.results.(['r' num2str(result_n)]).(stas{s}).xyz = data.xyz;
                    end
                end
            end
        end
        function loadFilesFromFolder(this, dir_path, pattern,result_n)
            % add all sinex present in a folder that match the pattern
            %
            % SYNTAX:
            %      this.loadFilesFromFolder(dir, pattern)
            if nargin < 3
                pattern = 'd*';
            end
            if nargin < 4
                result_n = 2;
            end
            files = dir(dir_path);
            for f = 1:length(files)
                if ~isempty(regexp(files(f).name,pattern))
                    this.addTropoSinexFile([dir_path filesep files(f).name],result_n);
                end
            end
        end
        function addReceivers(this, recs, result_n)
            % add rceeiver
            %
            % SYNTAX
            %     this.addTropoSinexFile(filename, <result_n>)
            
            if nargin < 3
                result_n = 1;
            end
            this.results.(['r' num2str(result_n)]) = struct();
            for s = 1:length(recs)
                sta = recs(s).getMarkerName4Ch;
                data = recs(s).out;
                if isfield(this.results.(['r' num2str(result_n)]), sta)
                    
                    [this.results.(['r' num2str(result_n)]).(sta).time, idx1, idx2] = this.results.(['r' num2str(result_n)]).(stas{s}).time.injectBatch(data.time);
                    this.results.(['r' num2str(result_n)]).(sta).ztd     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).ztd, data.ztd , idx1, idx2);
                    this.results.(['r' num2str(result_n)]).(sta).tgn     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).tgn, data.tgn, idx1, idx2);
                    this.results.(['r' num2str(result_n)]).(sta).tge     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).tge, data.tge, idx1, idx2);
                    
                    [this.results.(['r' num2str(result_n)]).(sta).coord_time, idx1, idx2] = this.results.(['r' num2str(result_n)]).(stas{s}).coord_time.injectBatch(data.time_pos);
                    this.results.(['r' num2str(result_n)]).(sta).xyz     = Core_Utils.injectData(this.results.(['r' num2str(result_n)]).(stas{s}).xyz, data.xyz, idx1, idx2);
                else
                    this.results.(['r' num2str(result_n)]).(sta) = struct();
                    this.results.(['r' num2str(result_n)]).(sta).xyz = data.xyz;
                    this.results.(['r' num2str(result_n)]).(sta).coord_time = data.time_pos;
                    this.results.(['r' num2str(result_n)]).(sta).time = data.time;
                    this.results.(['r' num2str(result_n)]).(sta).ztd = data.ztd;
                    this.results.(['r' num2str(result_n)]).(sta).tgn = data.tgn;
                    this.results.(['r' num2str(result_n)]).(sta).tge = data.tge;
                end
            end
        end
        
        function plotDifference(this,mode)
            % print the difference between the results
            %
            % SYNTAX 
            %   this.plotComparison()
            if nargin < 2
                mode = 1;
            end
            sta1 = fieldnames(this.results.r1);
            sta2 = fieldnames(this.results.r2);
            for s1 = 1 : length(sta1)
                for s2 = 1 : length(sta2)
                    if strcmpi(sta1{s1},sta2{s2})
                        data1 = this.results.r1.(sta1{s1});
                        data2 = this.results.r2.(sta2{s2});
                        f = figure; f.Name = sprintf('%03d: %s ', f.Number, sta1{s1}); f.NumberTitle = 'off';
                        % plot ZTD series
                        subplot(3,4,1:3)
                        diffint = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.ztd), data1.time.getMatlabTime, zero2nan(data1.ztd),'interpolate');
                        plot(data1.time.getMatlabTime,diffint,'.','Color','b');
                        hold on;
                        [diffagg] = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.ztd), data1.time.getMatlabTime, zero2nan(data1.ztd),'aggregate');
                        plot(data2.time.getMatlabTime,diffagg,'Color','r');
                        stdd = nan_std(diffint);
                        ylim([-4*stdd 4*stdd])
                        xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                        setTimeTicks(5,'yyyy/mm/dd');
                        title('ZTD')
                        subplot(3,4,4)
                        hist(noNaN(diffagg),30)
                        rms = mean(abs(noNaN(diffagg)*1e3));
                        bias = mean(noNaN(diffagg)*1e3);
                        title(sprintf('Bias: %0.2f mm RMS: %0.2f mm',bias,rms))
                        xlabel('Aggregated differences');
                        ylabel('#');
                        
                        if mode == 1
                            subplot(3,4,5:7)
                            diffint = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tge), data1.time.getMatlabTime, zero2nan(data1.tge),'interpolate');
                            plot(data1.time.getMatlabTime,diffint,'.','Color','b');
                            hold on;
                            [diffagg] = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tge), data1.time.getMatlabTime, zero2nan(data1.tge),'aggregate');
                            plot(data2.time.getMatlabTime,diffagg,'Color','r');
                            stdd = nan_std(diffint);
                            ylim([-4*stdd 4*stdd])
                            xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                            setTimeTicks(5,'yyyy/mm/dd');
                            title('East gradient')
                            subplot(3,4,8)
                            hist(noNaN(diffagg),30)
                            rms = mean(abs(noNaN(diffagg)*1e3));
                            bias = mean(noNaN(diffagg)*1e3);
                            title(sprintf('Bias: %0.2f mm RMS: %0.2f mm',bias,rms))
                            xlabel('Aggregated differences');
                            ylabel('#');
                            % plot gn series
                            subplot(3,4,9:11)
                            diffint = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tgn), data1.time.getMatlabTime, zero2nan(data1.tgn),'interpolate');
                            plot(data1.time.getMatlabTime,diffint,'.','Color','b');
                            hold on;
                            [diffagg] = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tgn), data1.time.getMatlabTime, zero2nan(data1.tgn),'aggregate');
                            plot(data2.time.getMatlabTime,diffagg,'Color','r');
                            stdd = nan_std(diffint);
                            ylim([-4*stdd 4*stdd])
                            xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                            setTimeTicks(5,'yyyy/mm/dd');
                            title('North gradient')
                            subplot(3,4,12)
                            hist(noNaN(diffagg),30)
                            rms = mean(abs(noNaN(diffagg)*1e3));
                            bias = mean(noNaN(diffagg)*1e3);
                            title(sprintf('Bias: %0.2f mm RMS: %0.2f mm',bias,rms))
                            xlabel('Aggregated differences');
                            ylabel('#');
                        else
                            % POLAR COORDINATES
                            subplot(3,4,5:7)
                            diffintE = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tge), data1.time.getMatlabTime, zero2nan(data1.tge),'interpolate');
                            [diffaggE] = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tge), data1.time.getMatlabTime, zero2nan(data1.tge),'aggregate');
                            diffintN = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tgn), data1.time.getMatlabTime, zero2nan(data1.tgn),'interpolate');
                            [diffaggN] = timeSeriesComparison(data2.time.getMatlabTime, zero2nan(data2.tgn), data1.time.getMatlabTime, zero2nan(data1.tgn),'aggregate');
                            subplot(3,4,5:7)
                            diffint = sqrt(diffintE.^2 + diffintN.^2);
                            plot(data1.time.getMatlabTime,diffint,'.','Color','b');
                            hold on;
                            diffagg = sqrt(diffaggE.^2 + diffaggN.^2);
                            plot(data2.time.getMatlabTime,diffagg,'Color','r');
                            stdd = nan_std(diffint);
                            ylim([0 7*stdd])
                            xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                            setTimeTicks(5,'yyyy/mm/dd');
                            title('Gradient magnitude')
                            subplot(3,4,8)
                            hist(noNaN(diffagg),30)
                            rms = mean(abs(noNaN(diffagg)*1e3));
                            bias = mean(noNaN(diffagg)*1e3);
                            title(sprintf('RMS: %0.2f mm',rms))
                            xlabel('Aggregated differences');
                            ylabel('#');
                            % plot gn series
                            subplot(3,4,9:11)
                            diffint = atan2(diffintE, diffintN)/pi*180; diffint(abs(diffint) > 180) = sign(diffint(abs(diffint) > 180)).*(360 - abs(diffint(abs(diffint) > 180)));
                            
                            plot(data1.time.getMatlabTime,diffint,'.','Color','b');
                            hold on;
                            diffagg = atan2(diffaggE, diffaggN)/pi*180; diffagg(abs(diffagg) > 180) = sign(diffagg(abs(diffagg) > 180)).*(360 - abs(diffagg(abs(diffagg) > 180)));
                            plot(data2.time.getMatlabTime,diffagg,'Color','r');
                            stdd = nan_std(diffint);
                            ylim([-180 180])
                            xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                            setTimeTicks(5,'yyyy/mm/dd');
                            title('Gradient Azimuth')
                            magn = sqrt(data2.tge.^2 + data2.tgn.^2);
                            diffagg = diffagg(magn > 3*1e-3);
                            subplot(3,4,12)
                            hist(noNaN(diffagg),30)
                            rms = mean(abs(noNaN(diffagg)));
                            bias = mean(noNaN(diffagg));
                            title(sprintf('Bias: %0.2f degree RMS: %0.2f degree',bias,rms))
                            xlabel('Aggregated differences');
                            ylabel('#');
                        end
                    end
                end
            end
            
        end
        
        function plotComparison(this)
            % print the difference between the results
            %
            % SYNTAX 
            %   this.plotComparison()
            sta1 = fieldnames(this.results.r1);
            sta2 = fieldnames(this.results.r2);
            for s1 = 1 : length(sta1)
                for s2 = 1 : length(sta2)
                    if strcmpi(sta1{s1},sta2{s2})
                        data1 = this.results.r1.(sta1{s1});
                        data2 = this.results.r2.(sta2{s2});
                        f = figure; f.Name = sprintf('%03d: %s ', f.Number, sta1{s1}); f.NumberTitle = 'off';
                        % plot ZTD series
                        subplot(3,1,1)
                        plot(data1.time.getMatlabTime,zero2nan(data1.ztd),'.','Color','b');
                        hold on;
                        plot(data2.time.getMatlabTime,zero2nan(data2.ztd),'r');
                        setTimeTicks(5,'yyyy/mm/dd');
                    
                        
                        xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                        title('ZTD')
                        % plot ge series
                        subplot(3,1,2)
                        plot(data1.time.getMatlabTime,zero2nan(data1.tge),'.','Color','b');
                        hold on;
                        plot(data2.time.getMatlabTime,zero2nan(data2.tge),'r');
                        %                     diffagg = timeSeriesComparison(data2.time.getMatlabTime,data2.tge,data1.time.getMatlabTime,data1.tge,'aggregate');
                        %                     plot(data2.time.getMatlabTime,diffagg,'r');
                        setTimeTicks(5,'yyyy/mm/dd');
                        %                     subplot(3,4,11)
                        %                     hist(diffint);
                        xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                        title('East gradient')
                        % plot gn series
                        subplot(3,1,3)
                        plot(data1.time.getMatlabTime,zero2nan(data1.tgn),'.','Color','b');
                        hold on;
                        plot(data2.time.getMatlabTime,zero2nan(data2.tgn),'r');
                        %                     diffagg = timeSeriesComparison(data2.time.getMatlabTime,data2.tgn,data1.time.getMatlabTime,data1.tgn,'aggregate');
                        %                     plot(data2.time.getMatlabTime,diffagg,'r');
                        setTimeTicks(5,'yyyy/mm/dd');
                        %                     subplot(3,4,12)
                        %                     hist(diffint);
                        xlim([data1.time.first.getMatlabTime data1.time.last.getMatlabTime])
                        title('North gradient')
                    end
                end
            end
            
        end
    end
    methods (Static)
        function [results] = parseMultiStationTropoSinex(filename)
            % parse a sinex fil containing tropopsheric products (e.g. the ones produced by epn)
            %
            % SYNTAX:
            %  [results] = Tropo_Sinex_Compare.parseMultiStationTropoSinex(filename)
            fid = fopen(filename);
            txt = fread(fid,'*char')';
            fclose(fid);
            
            % get new line separators
            nl = regexp(txt, '\n')';
            if nl(end) <  numel(txt)
                nl = [nl; numel(txt)];
            end
            lim = [[1; nl(1 : end - 1) + 1] (nl - 1)];
            lim = [lim lim(:,2) - lim(:,1)];
            % get starting block lines
            st_idxes = find(txt(lim(:,1)) == '+');
            end_idxes = find(txt(lim(:,1)) == '-');
            for i = 1:length(st_idxes)
                st_idx = st_idxes(i);
                end_idx = end_idxes(i);
                if strfind(txt(lim(st_idx,1): lim(st_idx,2)),'TROP/DESCRIPTION')
                    for l = st_idx : end_idx
                        if strfind(txt(lim(l,1): lim(l,2)),' SOLUTION_FIELDS_1')
                            pars = strsplit(strtrim(txt(lim(l,1): lim(l,2))));
                            pars(1) = [];
                            n_par = length(pars);
                            for i = 1: n_par
                                pars{i} = strrep(pars{i},'#','NUM_');
                                all_res.(pars{i}) = [];
                            end
                        end
                    end
                    
                elseif strfind(txt(lim(st_idx,1): lim(st_idx,2)),'TROP/STA_COORDINATES')
                    n_lin = end_idx - st_idx -2;
                    sta_4char = txt(repmat(lim(st_idx+2:end_idx-1,1),1,4) + repmat([1:4],n_lin ,1));
                    xyz = reshape(sscanf( (txt(repmat(lim(st_idx+2:end_idx-1,1),1,38) + repmat([17:54], n_lin,1)))','%f %f %f\n'),3,n_lin)';
                elseif strfind(txt(lim(st_idx,1): lim(st_idx,2)),'TROP/SOLUTION')
                    n_lin = end_idx - st_idx -2;
                    sta_4char_trp = txt(repmat(lim(st_idx+2:end_idx-1,1),1,4) + repmat([1:4],n_lin,1));
                    obs_lines = st_idx+2:end_idx-1;
                    idx_no_ast = txt(lim(obs_lines,1)) ~= '*';
                    idx_no_ast = obs_lines(idx_no_ast);
                    n_lin = length(idx_no_ast);
                    sta_4char_trp = txt(repmat(lim(idx_no_ast,1),1,4) + repmat([1:4],n_lin,1));
                    end_col = min(lim(idx_no_ast,3));
                    
                    data = reshape(sscanf( (txt(repmat(lim(idx_no_ast,1),1,end_col) + repmat([0 :(end_col-1)],n_lin,1)))',['%*s %f:%f:%f' repmat(' %f',1,n_par)] ),n_par+3,n_lin)';
                    year = data(:,1);
                    idx_70 = year<70;
                    year(idx_70) = year(idx_70) + 2000;
                    year(~idx_70) = year(~idx_70) + 1900;
                    doy = data(:,2);
                    sod = data(:,3);
                    for i = 1 : n_par
                        all_res.(pars{i}) = [all_res.(pars{i}) ;  data(:,3+i)/1e3]; % -> covert in meters
                    end
                end
                
            end
            for s = 1: size(sta_4char,1)
                c_sta_4char = sta_4char(s,:);
                idx_sta  = strLineMatch(sta_4char_trp,c_sta_4char);
                if sum(idx_sta) > 0
                    for i = 1 : n_par
                        results.(c_sta_4char).(pars{i}) = all_res.(pars{i})(idx_sta);
                    end
                    results.(c_sta_4char).time = GPS_Time.fromDoySod(year(idx_sta),doy(idx_sta),sod(idx_sta));
                    results.(c_sta_4char).xyz = xyz(s,:);
                end
            end
        end
        
    end
    
end
